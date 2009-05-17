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

  #   wiki.edit_locks => {:all => {:locked_by_id => user_id, :locked_at => Time},
  #                       section_name =>
  #                        {:locked_by_id => user_id, :locked_at => Time}, ...}
  #
  # accessor for +edit_locks+ attribute. The default value is +{}+
  serialize :edit_locks, Hash
  serialize_default :edit_locks, Hash.new

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
  def lock(time, user, section = :all)
    time = time.utc

    # no one should be able to lock more than one section at a time
    unlock_everything_by(user)
    # over write the existing lock if there's one. the caller is responsible
    # for not deleting important locks
    edit_locks[section] = {:locked_at => time, :locked_by_id => user.id}

    # save without versions or timestamps
    update_edit_locks_attribute(edit_locks)
  end

  # unlocks a previously locked wiki (or a section) so that it can be edited by anyone.
  def unlock(section = :all)
    if section == :all
      # wipe away everything. safer in case of stray locks
      edit_locks.clear
    else
      edit_locks.delete(section)
    end

    # save without versions or timestamps
    update_edit_locks_attribute(edit_locks)
  end

  def unlock_everything_by(user)
    edit_locks.each do |heading, attributes|
      unlock(heading) if attributes[:locked_by_id] == user.id
    end
  end

  # returns true if +section+ is locked by anyone
  def locked?(section = :all)
    update_expired_locks

    # find a lock for this section or all sections
    return edit_locks[section]
  end

  # returns the user id that has locked the +section+
  # if someone has locked +:all+ sections, returns that user's id
  # if section = +:all+ and no one has locked +:all+ but someone has locked something
  # (preventing editing of all sections at once) returns the first one that locked something
  def locked_by_id(section = :all)
    update_expired_locks

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
    update_expired_locks

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
  
  # returns an array of locked section names
  def locked_sections
    edit_locks.keys
  end

  def locked_section_by(user)
    sections = []
    edit_locks.each do |heading, attributes|
      return heading if attributes[:locked_by_id] == user.id
    end
    nil
  end
  
  def locked_sections_not_by(user)
    sections = []
    edit_locks.each do |heading, attributes|
      sections << heading if attributes[:locked_by_id] != user.id
    end
    sections
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
  # NOTE: for some reason, I am not sure why, calling wiki.save directly will
  #       not work, because the version number is not incremented.
  #       so, smart_save! must be the only way that the wiki gets saved.
  def smart_save!(params)
    if params[:version] and version > params[:version].to_i
      raise ErrorMessage.new("can't save your data, someone else has saved new changes first.")
    end

    unless params[:user] and params[:user].is_a? User
      raise ErrorMessage.new("User is required.")
    end

    unless editable_by?(params[:user])
      raise ErrorMessage.new("Cannot save your data, someone else has locked the page.")
    end

    # reinsert the section into the body
    self.body = params[:body]

    if recent_edit_by?(params[:user])
      save_without_revision
      versions.find_by_version(version).update_attributes(:body => body, :body_html => body_html, :updated_at => Time.now)
    else
      self.user = params[:user]

      # disable optimistic locking for saving the data with versioning
      # optimistic locking is used whenever edit_locks Hash is updated (and then versioning is disabled)
      without_locking {save!}
    end

    unlock
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

  #### PROTECTED METHODS #######
  protected

  def update_expired_locks
    # don't call repeatadly for the same object
    return if @expired_locks_updated
    @expired_locks_updated = true

    current_time = Time.zone.now

    updated_locks = edit_locks.reject do |section, lock|
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
