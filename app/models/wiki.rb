#  This is a generic versioned wiki, primarily used by the WikiPage,
#  but also used directly sometimes by other classes (like for Group's
#  landing page wiki's).
#
#     create_table "wiki_versions", :force => true do |t|
#       t.integer  "wiki_id",    :limit => 11
#       t.integer  "version",    :limit => 11
#       t.text     "body"
#       t.text     "body_html"
#       t.text     "raw_structure"
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
#       t.integer  "user_id",       :limit => 11
#       t.integer  "version",       :limit => 11
#       t.text     "raw_structure"
#     end
#
#     add_index "wikis", ["user_id"], :name => "index_wikis_user_id"
#

##

# requirements/ideas:
# 1. nothing should get saved until we say save!
# 2. updating body automatically updates html and structure
# 3. wiki should never get saved with body/body products mismatch
# 4. loaded wiki should see only the latest body products, if body was updated from outside
class Wiki < ActiveRecord::Base
  include WikiExtension::Locking
  include WikiExtension::Sections

  # a wiki can be used in multiple places: pages or profiles
  has_many :pages, :as => :data
  has_one :profile

  has_one :section_locks, :class_name => "WikiLock", :dependent => :destroy

  serialize :raw_structure, Hash

  # need more control than composed of
  attr_reader :structure

  before_save :update_body_html_and_structure
  before_save :update_latest_version_record


  # section locks should never be nil
  alias_method :existing_section_locks, :section_locks
  def section_locks(force_reload = false)
    # current section_locks or create a new one if it doesn't exist
    locks = (existing_section_locks(force_reload) || build_section_locks(:wiki => self))
    # section_locks should always have self as its wiki instance
    # in case self.body is updated (and section names get changed)
    locks.wiki = self
    locks
  end

  acts_as_versioned :if => :create_new_version? do
    def self.included(base)
      base.belongs_to :user
      base.serialize :raw_structure, Hash
    end
  end
  # versions are so tightly coupled that wiki.versions should always be up to date
  # this must be declared after acts_as_versioned, since AAV declares its own after_save
  # callback that create versions
  # locks should reloaded too, since some locks may become invalid (because of section heading changes)
  after_save :reload_versions_and_locks

  # only save a new version if the body has changed
  def create_new_version? #:nodoc:
    body_updated = body_changed?
    recently_edited_by_same_user = !user_id_changed? && (updated_at and (updated_at > 30.minutes.ago))

    latest_version_has_blank_body = self.versions.last && self.versions.last.body.blank?

    # always create a new version if we have no versions at all
    # don't create a new version if
    #   * a new version would be on top of an old blank version (we don't want to store blank versions)
    #   * the same user is making several edits in sequence
    #   * the body hasn't changed
    return (versions.empty? or (body_updated and !recently_edited_by_same_user and !latest_version_has_blank_body))
  end

  # returns first version since +time+
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
  end

  # reverts and deletes all versions after the reverted version.
  def revert_to_version!(version_number, user=nil)
    revert_to(version_number)
    destroy_versions_after(version_number)
  end

  # calls update_section! with :document section
  def update_document!(user, current_version, text)
    update_section!(:document, user, current_version, text)
  end

  # similar to update_attributes!, but only for text
  # this method will perform unlocking and will check version numbers
  # it will skip version_checking if current_version is nil (useful for section editing)
  def update_section!(section, user, current_version, text)
    if current_version and self.version > current_version.to_i
      raise ErrorMessage.new("can't save your data, someone else has saved new changes first.")
    end

    if sections_locked_for(user).include? section
      raise WikiLockError.new("Can't save '#{section}' since someone has locked it.")
    end

    unlock!(section, user)
    set_body_for_section(section, text)

    self.user = user
    self.save!
  end

  # updating body will invalidate body_html
  # reading body_html or saving this wiki
  # will regenerate body_html from body if render_body_html_proc is available
  def body=(body)
    write_attribute(:body, body)
    # invalidate body_html and raw_structure
    if body_changed?
      write_attribute(:body_html, nil)
      write_attribute(:raw_structure, nil)
      @structure = nil
    end
  end

  def clear_html
    write_attribute(:body_html, nil)
  end

  # will render if not up to date
  def body_html
    update_body_html_and_structure

    read_attribute(:body_html)
  end

  def preview_html
    render_preview(500)
  end

  # will calculate structure if not up to date
  # calculating structure will also update body_html
  def raw_structure
    update_body_html_and_structure

    read_attribute(:raw_structure) || write_attribute(:raw_structure, {})
  end

  def structure
    @structure ||= WikiExtension::WikiStructure.new(raw_structure, body.to_s)
  end

  # sets the block used for rendering the body to html
  def render_body_html_proc &block
    @render_body_html_proc = block
  end

  # renders body_html and calculates structure if needed
  def update_body_html_and_structure
    return unless needs_rendering?
    write_attribute(:body_html, render_body_html)
    write_attribute(:raw_structure, render_raw_structure)
  end

  # returns true if wiki body is fresher than body_html
  def needs_rendering?
    html = read_attribute(:body_html)
    rs = read_attribute(:raw_structure)

    # whenever we set body, we reset body_html to nil, so this condition will
    # be true whenever body is changed
    # it will also be true when body_html is invalidated externally (like with Wiki.clear_all_html)
    (html.blank? != body.blank?) or rs.blank?
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

  # reload the association
  def reload_versions_and_locks
    self.versions(true)
    # will clear out obsolete locks (expired or non-existant sections)
    self.section_locks(true)
  end

  ##
  ## RELATIONSHIP TO GROUPS
  ##

  # Clears the rendered HTML. This should be called when a group/user name is
  # changed or some other event happens which might affect how the HTML is
  # rendered by greencloth.
  def self.clear_all_html(owner)
    # for wiki's owned by pages
    Wiki.connection.execute(quote_sql([
      "UPDATE wikis, pages SET wikis.body_html = NULL WHERE pages.data_id = wikis.id AND pages.data_type = 'Wiki' AND pages.owner_id = ? AND pages.owner_type = ?",
      owner.id,
      owner.class.class_name
    ]))

    # for wiki's owned by by profiles
    Wiki.connection.execute(quote_sql([
      "UPDATE wikis, profiles SET wikis.body_html = NULL WHERE profiles.wiki_id = wikis.id AND profiles.entity_id = ? AND profiles.entity_type = ?",
      owner.id,
      owner.class.class_name
    ]))
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

  def render_preview(length)
    return unless content = truncated_body(length)
    if @render_body_html_proc
      @render_body_html_proc.call(content)
    else
      GreenCloth.new(content, link_context, [:outline]).to_html
    end
  end

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

  # returns html for wiki body
  # user render_body_html_proc if available
  # or default GreenCloth rendering otherwise
  def render_body_html
    if @render_body_html_proc
      @render_body_html_proc.call(body.to_s)
    else
      GreenCloth.new(body.to_s, link_context, [:outline]).to_html
    end
  end

  def render_raw_structure
    GreenCloth.new(body.to_s).to_structure
  end

  def truncated_body(length)
    return nil if body.nil?
    return body if body.length < length
    cut = body.to_s[0...length-3] + '...'
    cut.gsub! /^\[\[toc\]\]$/, ''
    cut
  end

  private


end
