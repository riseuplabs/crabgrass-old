#  This is a generic versioned wiki, primarily used by the WikiPage,
#  but also used directly sometimes by other classes (like for Group's
#  landing page wiki's).
#
#     create_table "wiki_versions", :force => true do |t|
#       t.integer  "wiki_id",    :limit => 11
#       t.integer  "version",    :limit => 11
#       t.text     "body"
#       t.text     "body_html"
#       t.datetime "updated_at"
#       t.integer  "user_id",    :limit => 11
#     end
#
#     add_index "wiki_versions", ["wiki_id"], :name => "index_wiki_versions"
#     add_index "wiki_versions", ["wiki_id", "updated_at"], :name => "index_wiki_versions_with_updated_at"
#
#     create_table "wikis", :force => true do |t|
#       t.text     "body"
#       t.text     "body_html"
#       t.datetime "updated_at"
#       t.integer  "user_id",      :limit => 11
#       t.integer  "version",      :limit => 11
#       t.integer  "lock_version", :limit => 11, :default => 0
#       t.text     "edit_locks"
#     end
#
#     add_index "wikis", ["user_id"], :name => "index_wikis_user_id"
#

class Wiki < ActiveRecord::Base

  serialize :edit_locks, HashWithIndifferentAccess

  belongs_to :user

  # a wiki can be used in multiple places: pages or profiles
  has_many :pages, :as => :data
  has_one :profile
  
  ##
  ## LOCKING
  ##

  # a word about timezones:
  # to get an attribute in UTC, you must do:
  #   wiki.locked_at_before_type_cast 
  # otherwise, the times reported by active record objects
  # are always local.

  LOCKING_PERIOD = 120.minutes

  # locks this wiki so that it cannot be edited by another user.
  # this method overwrites existing locks.
  def lock(time, locked_by, section = :all)
    time = time.utc

    # over write the existing lock if there's one. the caller is responsible
    edit_locks[section] = {:locked_at => time, :locked_by_id => locked_by.id}
    edit_locks[section][:locked_section] = section unless section == :all

    # save without versions or timestamps
    update_edit_locks_attribute(edit_locks)
  end

  # unlocks a previously locked wiki (or a section) so that it can be edited by anyone.
  def unlock(section = :all)
    if section.to_sym == :all
      # wipe away everything. safer in case of stray locks
      edit_locks.clear
    else
      edit_locks.delete(section)
    end

    # save without versions or timestamps
    update_edit_locks_attribute(edit_locks)
  end

  # returns true if +section+ is locked by anyone
  def locked?(section = :all)
    update_expired_locks unless @expired_locks_updated

    # find a lock for this section or all sections
    return edit_locks[section]
  end

  # returns the user id that has locked the +section+
  # if someone has locked +:all+ sections, returns that user's id
  # if section = +:all+ and no one has locked +:all+ but someone has locked something
  # (preventing editing of all sections at once) returns the first one that locked something
  def locked_by_id(section = :all)
    update_expired_locks unless @expired_locks_updated

    if edit_locks[section]
      return edit_locks[section][:locked_by_id]
    elsif edit_locks[:all]
      return edit_locks[:all][:locked_by_id]
    elsif section == :all and !edit_locks.empty?
      # no one has locked :all (or previous conditions would have been true)
      # but someone has locked some sections (maybe more than one), so we can't edit
      # :all, let's return the earliest locker
      locks = edit_locks.values.sort do |lock1, lock2|
        lock1[:locked_at] <=> lock2[:locked_at]
      end
      return locks.first[:locked_by_id]
    else
      return nil
    end
  end

  # returns true if +section+ is locked by user
  # unlike +locked_by_id+ method this method will not
  # count a single section to be locked by +user+ when
  # that user has locked :all sections
  def locked_by?(user, section = :all)
    return !edit_locks[section].nil? && edit_locks[section][:locked_by_id] == user.id
  end


  # returns true if the page is free to be edited by +user+ (ie, not locked by someone else)
  def editable_by?(user, section = :all)
    update_expired_locks unless @expired_locks_updated

    if section != :all and edit_locks[:all]
      # we're trying to edit a section while the whole thing is locked
      return false
    elsif edit_locks[:all].nil? and section == :all and !edit_locks.empty?
      # we're being asked if we can edit :all (whole page).
      # no one has locked :all, but someone has locked one or more sections
      # so we can't edit :all
      return false
    elsif edit_locks[section].nil? or edit_locks[section][:locked_by_id] == user.id
      # we have no lock for this section or the lock belongs to this user
      return true
    else
      return false
    end
  end

  # :call-seq:
  #   wiki.edit_locks => {:all => {:locked_by_id => user_id, :locked_at => Time}, 
  #                       section_index(Fixnum) =>
  #                        {:locked_section => n, :locked_by_id => user_id, :locked_at => Time}, ...}
  #
  # accessor for +edit_locks+ attribute. The default value is +{}+
  # +locked_section+ is the index of the section the user decided to lock
  # since section indeces are unstable (deleting/inserting sections at a low number index changes all the later indexes),
  # we track +locked_section+ which is the latest index identifying the section user locked
  def edit_locks
    # return [] if the attribute is not set
    read_attribute(:edit_locks) || write_attribute(:edit_locks, HashWithIndifferentAccess.new)
  end

  # When the user sends a request to submit an updated section
  # they use a section index to refer to what they want to update
  # this makes it possible they they are referencing to the wrong section
  # (previous users split/merged sections while this one was working and that changes section indexes)
  #
  # this method uses +edit_lcoks+ to convert a +section+ index +user+ thinks refers to a particular section
  # to a the section index that correctly identifies the section of the wiki body
  def resolve_updated_section_index(section, user)
    return :all if section.blank? or section.to_sym == :all

    edit_locks.each do |current_section_index, lock|
      if lock[:locked_section].to_i == section.to_i
        if user.nil? or lock[:locked_by_id] == user.id
          # update the section user holds and return it
          lock[:locked_section] = current_section_index
          return current_section_index.to_i
        end
      end
    end

    return section.to_i
  end

  ##
  ## VERSIONING
  ##

  acts_as_versioned :if => :save_new_version? do 
    # these methods are added to both Wiki and Wiki::Version

    def body=(value) # :nodoc: 
      write_attribute(:body, value)
      write_attribute(:body_html, "")
    end

    # Clears the html rendered body (body_html). A cleared body_html will get
    # autogenerated when it is needed.
    def clear_html
      update_attribute(:body_html, nil)
    end

    # render_html is responsible for rendering wiki text to html markup.
    #
    # This rendering, however, is not handled by the wiki class: the block passed
    # to render_html() does the conversion.
    #
    # render_html() should be called whenever the body_html needs to be shown, but
    # the block will only actually get called if body_html needs updating.
    #
    # Example usage:
    #
    #   wiki.body_html # << not valid yet
    #   wiki.render_html do |text|
    #      GreenCloth.new(text).to_html
    #   end
    #   wiki.body_html # << now it is valid
    #
    def render_html(&block)
      if body.empty?
        self.body_html = "<p></p>"
      elsif body_html.empty? 
        self.body_html = block.call(body)
      end
      if body_html_changed?
        without_timestamps do
          if respond_to? :save_without_revision
            save_without_revision!
          else
            save!
          end
        end
      end
    end 
  end

  self.non_versioned_columns << 'edit_locks' << 'lock_version'


  # only save a new version if the body has changed
  # and was not previously nil
  def save_new_version? #:nodoc:
    self.body_changed? and self.body_was.any?
  end
  
  # returns true if the last version was created recently by this same author.
  def recent_edit_by?(author)
    (user == author) and updated_at and (updated_at > 30.minutes.ago)
  end 
  
  # returns first version since @time@
  def first_since(time)
    return nil unless time
    versions.first :conditions => ["updated_at <= :time", {:time => time}],
      :order => "updated_at DESC"
  end

  ##
  ## SAVING
  ##
  
  # 
  # a smart update of the wiki, taking into account locking
  # and the last time the wiki was saved by the same person.
  #
  # tries to save, throws an exception if anything goes wrong.
  # possible exceptions:
  #   ActiveRecord::StaleObjectError
  #   ErrorMessage
  #
  def smart_save!(params)
    params[:section] ||= :all

    if params[:section] == :all and params[:version] and version > params[:version].to_i
      raise ErrorMessage.new("can't save your data, someone else has saved new changes first.")
    end

    unless params[:user] and params[:user].is_a? User
      raise ErrorMessage.new("User is required.")
    end

    unless editable_by?(params[:user], params[:section])
      lock_scope = "section #{params[:section]}"

      if params[:section] == :all
        lock_scope = "page"
      else
        lock_scope = "section #{params[:section]}"
      end

      raise ErrorMessage.new("Cannot save your data, someone else has locked the #{lock_scope}.")
    end

    # reinsert the section into the body
    self.body = reconstitute_body(params[:section], params[:body])

    # # handle splits/merges
    # updated_locks = restore_body_and_adjust_locks(params)

    # handle merge/split situations that might mean lock for section index N is now a lock for section
    # index N+1 or N-1
    updated_locks = calculate_adjusted_edit_locks(params[:section], params[:body])

    if recent_edit_by?(params[:user])
      save_without_revision
      versions.find_by_version(version).update_attributes(:body => body, :body_html => body_html, :updated_at => Time.now)
    else
      self.user = params[:user]

      # disable optimistic locking for saving the data with versioning
      # optimistic locking is used whenever edit_locks Hash is updated (and then versioning is disabled)
      without_locking {save!}
    end

    update_edit_locks_attribute(updated_locks)
  end

  def reconstitute_body(section, text)
    reconsituted_body = ""

    if section.blank? or section == :all
      # editing the whole document
      reconsituted_body = text
    else
      sections = self.sections

      # restore the body
      sections[section.to_i] = text
      reconsituted_body

      sections.each_with_index do |s, i|
        reconsituted_body << s
        if i == section.to_i
          # don't let users to update sections in a way
          # that would merge them into the next section
          reconsituted_body << "\n" unless s =~ /\n\Z/
        end
      end
    end

    return reconsituted_body
  end

  ##### RENDERING #################################
 
  def body=(value)
    write_attribute(:body, value)
    write_attribute(:body_html, "")
  end
 
  def clear_html
    update_attribute(:body_html, nil)
  end

  # render_html is responsible for rendering wiki text to html markup.
  #
  # This rendering, however, is not handled by the wiki class: the block passed
  # to render_html() does the conversion.
  #
  # render_html() should be called whenever the body_html needs to be shown, but
  # the block will only actually get called if body_html needs updating.
  #
  # Example usage:
  #
  #   wiki.body_html # << not valid yet
  #   wiki.render_html do |text|
  #      GreenCloth.new(text).to_html
  #   end
  #   wiki.body_html # << now it is valid
  #
  def render_html(&block)
    if body.empty?
      self.body_html = "<p></p>"
    elsif body_html.empty? 
      self.body_html = block.call(body)
    end
    if body_html_changed?
      without_timestamps do
        save_without_revision!
      end
    end
  end
  
  ##
  ## RELATIONSHIP TO GROUPS
  ##
  
  # clears the rendered html. this is called
  # when a group's name is changed or some other event happens
  # which might affect how the html is rendered by wholecloth.
  # this only clears the primary group's wikis, which should be fine
  # because default_group_name just uses the primary group's name.
  def self.clear_all_html(group)
    # for wiki's owned by pages
    Wiki.connection.execute("UPDATE wikis set body_html = NULL WHERE id IN (SELECT data_id FROM pages WHERE data_type='Wiki' and group_id = #{group.id.to_i})")
    # for wiki's owned by groups
    Wiki.connection.execute("UPDATE wikis set body_html = NULL WHERE id IN (SELECT wiki_id FROM profiles WHERE entity_id = #{group.id.to_i})")
  end
  
  def default_group_name # :nodoc #
    if page and page.group_name
      #.sub(/\+.*$/,'') # remove everything after +
      page.group_name
    elsif profile
      profile.entity.name
    else
      'page'
    end
  end
  
  ##
  ## RELATIONSHIP TO PAGES
  ##
    
  # returns the page associated with this wiki, if any.
  def page
    # we do this so that we can access the page even before page or wiki are saved
    return pages.first if pages.any?
    return @page
  end
  def page=(p) #:nodoc:
    @page = p
  end
  
  #### SECTIONS ########

  # returns an array of all sections
  def sections
    GreenCloth.new(body).sections
  end

  #### PROTECTED METHODS #######
  protected

  # we need to deal with the fact that users hold locks to sections by index
  # and that a preceding index section can get deleted (by setting the body to '')
  # or when a preceding section can get merged/split (by adding removing headings)
  # in those cases the user will try to update the wrong section index.
  # so we must store additional info in the +edit_locks+ hash (+locked_section+ value).
  #
  # here we update the keys in +edit_locks+ hash
  # (which represend the actual current sections getting locked)
  def calculate_adjusted_edit_locks(section_index, updated_section_body)

    # the sections (could be none) that will replace the single section identified by section_index
    new_sections = GreenCloth.new(updated_section_body).sections

    # the number of new sections we are adding to replace this single section
    # each new section, except the first one (which might get merged into the previous section)
    # is counted
    updated_sections_count = new_sections.size - 1

    # we must determine if we should count the first one
    first_section_is_heading = GreenCloth.is_heading_section?(new_sections.first)

    if first_section_is_heading
      # the simplest case, it doesn't matter where these new sections are going
      # because the first one is clearly delimited and can't be merged
      updated_sections_count += 1
    elsif new_sections.size == 1 and !(new_sections.first =~ /\n/) and new_sections.first =~ /^\s*$/
      # we're deleting a section
      updated_sections_count = 0
    elsif section_index == 0
      # we'll be inserting a section without a heading to replace the current section
      # in most cases this text without heading will become a part of the previous section
      # (i.e. section with section_index - 1)
      # unless we're dealing with section_index = 0 then even a fragment of text is a real section
      updated_sections_count += 1
    end

    # how many sections we're adding to the total number of sections
    # 1 represents the current section that is being replaced
    section_index_offset = updated_sections_count - 1

    unless section_index_offset == 0
      adjusted_locks = move_edit_lock_section_indexes(section_index, section_index_offset)
    else
      adjusted_locks = edit_locks
    end

    return adjusted_locks
  end

  # update every section lock for a section > starting_section_index
  # by incrementing it by index_offset
  def move_edit_lock_section_indexes(starting_section_index, index_offset)
    # update each section_index key that is affected by this change
    updated_locks = HashWithIndifferentAccess.new

    # we might need to override the lock for the current section.
    # when we deleting the current section the directly following section
    # needs to be moved down and it will replace this current section lock
    replacable_lock = edit_locks[starting_section_index]
    edit_locks.each do |section_index, lock|
      # only sections following the one we're replacing need to be updated
      if section_index.is_a? Fixnum and section_index > starting_section_index.to_i
        new_section_index = section_index + index_offset
      else
        new_section_index = section_index
      end

      # recreate the lock with a new index
      # don't replace existing keys unless they are the section that we are saving over
      if !updated_locks.include?(new_section_index) or updated_locks[new_section_index] == replacable_lock
        updated_locks[new_section_index] = lock
      end
    end

    return updated_locks
  end

  def update_expired_locks
    @expired_locks_updated = true
    current_time = Time.zone.now

    updated_locks = edit_locks.reject do |section_index, lock|
      # reject if past due and time is used
      lock[:locked_at] and lock[:locked_at] + LOCKING_PERIOD < current_time
    end

    # save locks if something changed
    update_edit_locks_attribute(updated_locks) if updated_locks != edit_locks
  end

  def update_edit_locks_attribute(updated_locks)
    without_revision do
      without_timestamps do
        update_attribute(:edit_locks, updated_locks)
      end
    end
  end

end
