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

##

class Wiki < ActiveRecord::Base
  include WikiExtension::Locking
  include WikiExtension::Sections
  

  # a wiki can be used in multiple places: pages or profiles
  has_many :pages, :as => :data
  has_one :profile
  has_one :section_locks, :class_name => "WikiLock", :dependent => :destroy


  serialize :raw_structure, Hash

  composed_of :structure, :class_name => "WikiExtension::WikiStructure", :mapping => %w(raw_structure)

  before_save :update_body_html_and_structure
  before_save :update_latest_version_record

  ##
  ## LOCKING
  ##
  #  def section_heading_names
  #    greencloth.heading_names
  #  end
  #
  #  def subsection_heading_names(section)
  #    return section_heading_names if section == :all
  #    greencloth.subheading_names(section)
  #  end
  #
  #  def parent_section_heading_names(section)
  #    greencloth.parent_heading_names(section)
  #  end
  #
  #  def greencloth
  #    @greencloth ||= GreenCloth.new(self.body)
  #  end

  ##
  ## VERSIONING
  ##

  acts_as_versioned :if => :create_new_version? do
    # these methods are added to both Wiki and Wiki::Version

    def self.included(base)
      base.belongs_to :user
    end
  end



  # only save a new version if the body has changed
  # and was not previously nil
  def create_new_version? #:nodoc:
    body_updated = body_changed? #and body_was.any?
    recently_edited_by_same_user = !user_id_changed? and (updated_at and (updated_at > 30.minutes.ago))

    return versions.empty? || (body_updated && !recently_edited_by_same_user)
  end


  # returns first version since @time@
  def first_version_since(time)
    return nil unless time
    versions.first :conditions => ["updated_at <= :time", {:time => time}],
      :order => "updated_at DESC"
  end

  # reverts and keeps all the old versions
  def revert_to_version(version_number, user)
    version = versions.find_by_version(version_number)
    self.body = version.body
    self.user = user
    save!
    smart_save!(:body => version.body, :user => user)
  end

  # reverts and deletes all versions after the reverted version.
  def revert_to_version!(version_number, user=nil)
    revert_to(version_number)
    destroy_versions_after(version_number)
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
  # def smart_save!(params)
  #   params[:heading] ||= :all
  #
  #
  #   unless editable_by?(params[:user], params[:heading])
  #     raise ErrorMessage.new("Cannot save your data, someone else has locked the page.")
  #   end
  #
  #   self.body = params[:body]
  #
  #   if recent_edit_by?(params[:user])
  #     save_without_revision
  #     versions.find_by_version(version).update_attributes(:body => body, :body_html => body_html, :updated_at => Time.now)
  #   else
  #     self.user = params[:user]
  #
  #     # disable optimistic locking for saving the data with versioning
  #     # optimistic locking is used whenever edit_locks Hash is updated (and then versioning is disabled)
  #     without_locking {save!}
  #   end
  #
  #   unlock(params[:heading])
  # end

  def update_document!(user, current_version, text)
    update_section!(:document, user, current_version, text)
  end

  def update_section!(section, user, current_version, text)
    if self.version > current_version
      raise ErrorMessage.new("can't save your data, someone else has saved new changes first.")
    end

    if sections_locked_for(user).include? section
      raise ErrorMessage.new("Can't save '#{section}' since someone has locked it.")
    end

    set_body_from_section(section, text)
    unlock!(section, user)

    self.user = user
    self.save!
  end

  ##### RENDERING #################################

  # def body=(value)
  #   write_attribute(:body, value)
  #   write_attribute(:body_html, "")
  # end
  #
  # def clear_html
  #   update_attribute(:body_html, nil)
  # end

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
  # def render_html(&block)
  #   if body.empty?
  #     self.body_html = "<p></p>"
  #   elsif body_html.empty?
  #     self.body_html = block.call(body)
  #   end
  #   if body_html_changed?
  #     without_timestamps do
  #       save_without_revision!
  #     end
  #   end
  # end

  # updating body will invalidate body_html
  # reading body_html or saving this wiki
  # will regenerate body_html from body if render_body_html_proc is available
  def body=(body)
    require 'ruby-debug';debugger;1-1
    write_attribute(:body, body)
    # invalidate body_html and raw_structure
    if body_changed?
      write_attribute(:body_html, nil)
      write_attribute(:raw_structure, {})
    end
  end

  # will render if not up to date
  def body_html
    update_body_html_and_structure

    without_timestamps { save_without_revision! } if body_html_changed? and !new_record?
    read_attribute(:body_html)
  end

  # will render if not up to date
  def raw_structure
    update_body_html_and_structure
    without_timestamps { save_without_revision! } if raw_structure_changed? and !new_record?

    read_attribute(:raw_structure) || write_attribute(:raw_structure, {})
  end
  
  def section_locks
    WikiLock.find_by_wiki_id(self.id) || create_section_locks
  end

  # sets the block used for rendering the body to html
  def render_body_html_proc &block
    @render_body_html_proc = block
  end

  # returns html for wiki body
  # user render_body_html_proc if available
  # or default GreenCloth rendering otherwise
  def render_body_html
    if @render_body_html_proc
      @render_body_html_proc.call(body.to_s)
    else
      GreenCloth.new(body, link_context, [:outline]).to_html
    end
  end

  # renders body_html and calculates structure if needed
  def update_body_html_and_structure
    return unless needs_rendering?
    write_attribute(:body_html, render_body_html)
    write_attribute(:raw_structure, GreenCloth.new(body.to_s).to_structure)
  end

  # returns true if wiki body is fresher than body_html
  def needs_rendering?
    html = read_attribute(:body_html)
    rs = read_attribute(:raw_structure)

    # whenever we set body, we reset body_html to nil, so this condition will
    # be true whenever body is changed
    # it will also be true when body_html is invalidated externally (like with Wiki.clear_all_html)
    (html.blank? != body.blank?) or (rs.blank? != body.blank?)
  end

  # update the latest Wiki::Version object with the newest attributes
  # when wiki changes, but a new version is not being created
  def update_latest_version_record
    # only need to update the latest version when not creating a new one
    return if create_new_version?
    versions.find_by_version(self.version).update_attributes(
              :body => body,
              # read_attributes for body_html and raw_structure
              # because we don't want to trigger another rendering
              # by calling our own body_html method
              :body_html => read_attribute(:body_html),
              :raw_structure => read_attribute(:raw_structure),
              :user => user,
              :updated_at => Time.now)
  end

  ##
  ## RELATIONSHIP TO GROUPS
  ##

  # clears the rendered html. this is called
  # when a group's name is changed or some other event happens
  # which might affect how the html is rendered by greencloth.
  # this only clears the primary group's wikis, which should be fine
  # because link_context just uses the primary group's name.
  def self.clear_all_html(group)
    # for wiki's owned by pages
    Wiki.connection.execute("UPDATE wikis set body_html = NULL WHERE id IN (SELECT data_id FROM pages WHERE data_type='Wiki' and group_id = #{group.id.to_i})")
    # for wiki's owned by groups
    Wiki.connection.execute("UPDATE wikis set body_html = NULL WHERE id IN (SELECT wiki_id FROM profiles WHERE entity_id = #{group.id.to_i})")
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

  ##
  ## PROTECTED METHODS
  ##

  protected

  # # used when wiki is rendered for deciding the prefix for some link urls
  def link_context
    if page and page.owner_name
      #.sub(/\+.*$/,'') # remove everything after +
      page.owner_name
    elsif profile
      profile.entity.name
    else
      'page'
    end
  end

  def destroy_versions_after(version_number)
    versions.find(:all, :conditions => ["version > ?", version_number]).each do |version|
      version.destroy
    end
  end

  private

  ## this is really confusing and needs to be cleaned up.
  ##
  ## if this is passed a section which we don't think exists, then the wiki
  ## appears to be locked. This is a problem, because then you cannot ever
  ## unlock the wiki.
  ##
  ## the hacky solution for now is to add this missing section to available
  ## sections.
  ##
  ## also, without the hacky line, trying to edit a newly created wiki
  ## throws an error that it is locked!
  ##
  ## also, if self.body == nil, then don't check the sections, because it will
  ## bomb out.
  ##
  # def section_is_available_to_user(user, section)
  #   if self.body.nil?
  #     return editable_by?(user)
  #   end
  #
  #   available_sections = sections_not_locked_for(user)
  #
  #   ## here is the hacky line:
  #   available_sections << section unless section_heading_names.include?(section)
  #
  #   # the second clause (locked_by_id == ...) will include :all section
  #   available_sections.include?(section) || self.locked_by_id(section) == user.id
  # end

end
