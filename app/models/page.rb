=begin

PAGE.RB

A Page is the main content class. All actual content is a subclass of this class.

denormalization
---------------

  * updated_by_login
  * created_by_login
  * owner_name

Upon further investigation, I am not sure that these are needed.

schema
--------

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "resolved",                         :default => true
    t.boolean  "public"
    t.integer  "created_by_id",      :limit => 11
    t.integer  "updated_by_id",      :limit => 11
    t.text     "summary"
    t.string   "type"
    t.integer  "message_count",      :limit => 11, :default => 0
    t.integer  "data_id",            :limit => 11
    t.string   "data_type"
    t.integer  "contributors_count", :limit => 11, :default => 0
    t.integer  "posts_count",        :limit => 11, :default => 0
    t.string   "name"
    t.string   "updated_by_login"
    t.string   "created_by_login"
    t.integer  "flow",               :limit => 11
    t.integer  "stars",              :limit => 11, :default => 0
    t.integer  "views_count",        :limit => 11, :default => 0,    :null => false
    t.integer  "owner_id",           :limit => 11
    t.string   "owner_type"
    t.string   "owner_name"
    t.boolean  "is_image"
    t.boolean  "is_audio"
    t.boolean  "is_video"
    t.boolean  "is_document"
    t.integer  "site_id",            :limit => 11
    t.datetime "happens_at"
  end

  add_index "pages", ["name","owner_id"], :name => "index_pages_on_name"
  add_index "pages", ["created_by_id"], :name => "index_page_created_by_id"
  add_index "pages", ["updated_by_id"], :name => "index_page_updated_by_id"
  add_index "pages", ["type"], :name => "index_pages_on_type"
  add_index "pages", ["flow"], :name => "index_pages_on_flow"
  add_index "pages", ["public"], :name => "index_pages_on_public"
  add_index "pages", ["resolved"], :name => "index_pages_on_resolved"
  add_index "pages", ["created_at"], :name => "index_pages_on_created_at"
  add_index "pages", ["updated_at"], :name => "index_pages_on_updated_at"
  execute "CREATE INDEX owner_name_4 ON pages (owner_name(4))"

  Yeah, so, there are way too many indices on the pages table.
=end

class Page < ActiveRecord::Base
  extend PathFinder::FindByPath
  include PageExtension::Users     # page <> users relationship
  include PageExtension::Groups    # page <> group relationship
  include PageExtension::Assets    # page <> asset relationship
  include PageExtension::Create    # page creation
  include PageExtension::Subclass  # page subclassing
  include PageExtension::Index     # page full text searching
  include PageExtension::Starring  # ???
  include PageExtension::Tracking  # page tracking views, edits and stars
  include PageExtension::PageHistory  

  # disable timestamps, we set the updated_at field through certain PageHistory subclasses
  self.record_timestamps = false
  before_save :save_timestamps

  acts_as_taggable_on :tags
  acts_as_site_limited
  attr_protected :owner

  ##
  ## NAMES SCOPES
  ##

  named_scope :only_public, :conditions => {:public => true}
  named_scope :only_images, :conditions => {:is_image => true}
  named_scope :only_videos, :conditions => {:is_video => true}

  ##
  ## PAGE NAMING
  ##

  def validate
    if (name_changed? or owner_id_changed? or groups_changed) and name_taken?
      errors.add 'name', 'is already taken'
    elsif name_changed? and name.any?
      errors.add 'name', 'name is invalid' if name != name.nameize
    end
  end

  def name_url
    name.any? ? name : friendly_url
  end

  def flow= flow
    if flow.kind_of?(Integer) || flow.nil?
      write_attribute(:flow, flow)
    elsif flow.kind_of?(Symbol) && FLOW[flow]
      write_attribute(:flow, FLOW[flow])
    else
      raise TypeError.new("Flow needs to be an integer or one of [#{FLOW.keys.join(', ')}]")
    end
  end

  def delete
    self.flow=:deleted
    self.save
  end

  def undelete
    write_attribute(:flow, nil)
    self.save
  end

  def deleted?
    flow == FLOW[:deleted]
  end

  def friendly_url
    s = title.nameize
    s = s[0..40].sub(/-([^-])*$/,'') if s.length > 42     # limit name length, and remove any half-cut trailing word
    "#{s}+#{id}"
  end

  # using only knowledge of this page, returns
  # best guess uri string, sans protocol/host/port.
  # ie /rainbows/what-a-fine-page+5234
  def uri
    owner_name.any? ? [owner_name, name_url].path : ['page', friendly_url].path
  end

  # returns true if self's unique page name is already in use.
  # what pages are in the namespace? all pages connected to all
  # groups connected to this page (include the group's committees too).
  # it also includes the user owner of this page
  def name_taken?
    return false unless self.name.any?
    p = Page.find(:first,
      :conditions => ['pages.name = ? and group_participations.group_id IN (?)', self.name, self.namespace_group_ids],
      :include => :group_participations
    )
    p ||= Page.find_by_name_and_owner_id(self.name, self.owner.id) if self.owner_type == 'User'
    return false if p.nil?
    return self != p
  end

  ##
  ## RELATIONSHIP TO PAGE DATA
  ##

  belongs_to :data, :polymorphic => true, :dependent => :destroy
  has_one :discussion, :dependent => :destroy

  validates_presence_of :title
  validates_associated :data
  validates_associated :discussion

  def unresolve
    resolve(false)
  end
  def resolve(value=true)
    user_participations.each do |up|
      up.resolved = value
      up.save
    end
    self.resolved=value
    save
  end

  def build_post(post,user)
    # this looks like overkill, but it seems to be needed
    # in order to build the post in memory and have it saved when
    # (possibly new) pages is saved
    self.discussion ||= Discussion.new
    self.discussion.page = self
    if post.instance_of? String
      post = Post.new(:body => post)
    end
    self.discussion.posts << post
    post.discussion = self.discussion
    post.user = user
    association_will_change(:posts)
    return post
  end

  def association_will_change(assn)
    (@associations_to_save ||= []) << assn
  end

  def association_changed?
    @associations_to_save.any?
  end

  after_save :save_associations
  def save_associations
    return true unless @associations_to_save
    @associations_to_save.uniq.each do |assn|
      if assn == :posts
        discussion.posts.each {|post| post.save! if post.changed?}
      elsif assn == :users
        user_participations.each {|up| up.save! if up.changed?}
      elsif assn == :groups
        group_participations.each {|gp| gp.save! if gp.changed?}
      end
    end
    true
  end

  before_save :update_posts_count
  def update_posts_count
    if posts_count_changed?
      self.posts_count = self.discussion.posts_count if self.discussion
    end
  end


  ##
  ## PAGE ACCESS CONTROL
  ##

  public

  # This method should never be called directly. It should only be called
  # from User#may?()
  #
  # possible permissions:
  #   :view  -- user can see the page.
  #   :edit  -- user can participate.
  #   :admin -- user can destroy the page, change access.
  #   :none  -- always returns false
  #
  # :view should only return true if the user has access to view the page
  # because of participation objects, NOT because the page is public.
  #
  # DEPRECATED BEHAVIOR:
  # :edit should return false for deleted pages.
  #
  def has_access!(perm, user)

    ########################################################
    ## THESE ARE TEMPORARY HACKS...
    return false if tmp_hack_for_deleted_pages?(perm)
    ## END TEMP HACKS
    #########################################################

    asked_access_level = ACCESS[perm] || ACCESS[:view]
    participation = most_privileged_participation_for(user)
    allowed = if participation.nil?
      false
    else
      actual_access_level = participation.access || ACCESS[:view]
      asked_access_level >= actual_access_level
    end

    allowed ? true : raise(PermissionDenied.new)
  end

  # returns the participation object for entity with the highest access level.
  # If no participation exists, we return nil.
  def most_privileged_participation_for(entity)
    parts = []
    if entity.is_a? User
      parts << participation_for_user(entity)
      parts.concat participation_for_groups(entity.all_group_ids)
    elsif entity.is_a? Group
      parts << participation_for_group(entity)
    end
    parts.compact.min {|a,b| (a.access||100) <=> (b.access||100) }
  end

  protected

  # do not allow comments or editing of deleted pages:
  def tmp_hack_for_deleted_pages?(perm)
    self.deleted? and (perm == :edit)
  end

  ##
  ## RELATIONSHIP TO ENTITIES (GROUPS OR USERS)
  ##

  public

  # Add a group or user to this page (by creating a corresponing
  # user_participation or group_participation object). This is the only way
  # that groups or users should be added to pages!
  def add(entity, attributes={})
    if entity.is_a? Enumerable
      entity.collect do |e|
        e.add_page(self,attributes)
      end
    else
      entity.add_page(self,attributes)
    end
  end

  # Remove a group or user from this page (by destroying the corresponing
  # user_participation or group_participation object). This is the only way
  # that groups or users should be removed from pages!
  def remove(entity)
    if entity.is_a? Enumerable
      entity.each do |e|
        e.remove_page(self)
      end
    else
      entity.remove_page(self)
    end
    entity
  end

  # The owner may be a user or a group, or their name.
  # this attr is protected from mass assignment.
  def owner=(entity)
    if entity.is_a? String
      if entity.empty?
        entity = nil
      else
        entity = User.find_by_login(entity) || Group.find_by_name(entity)
      end
    end
    if entity.nil?
      if Conf.ensure_page_owner?
        raise ErrorMessage.new("Page owner cannot be empty."[:page_owner_error])
      else
        self.owner_id = nil
        self.owner_name = nil
        self.owner_type = nil
      end
    elsif self.owner_name != entity.name
      self.owner_id = entity.id
      self.owner_name = entity.name
      if entity.is_a? Group
        self.owner_type = "Group"
      elsif entity.is_a? User
        self.owner_type = "User"
      else
        raise Exception.new('must be user or group')
      end
      part = most_privileged_participation_for(entity)
      self.add(entity, :access => :admin) unless part and part.access == ACCESS[:admin]
      return self.owner(true)
    end
  end

  # updates the denormalized copies of owner name
  def self.update_owner_name(owner)
    Page.connection.execute(quote_sql([
      "UPDATE pages SET `owner_name` = ? WHERE pages.owner_id = ? AND pages.owner_type = ?",
      owner.name,
      owner.id,
      owner.class.class_name
    ]))
    if owner.is_a? User
      Page.connection.execute(quote_sql([
        "UPDATE pages SET updated_by_login = ? WHERE pages.updated_by_id = ?",
        owner.login, owner.id
      ]))
      Page.connection.execute(quote_sql([
        "UPDATE pages SET created_by_login = ? WHERE pages.created_by_id = ?",
        owner.login, owner.id
      ]))
    end
  end

  # returns the appropriate user_participation or group_participation record.
  # it would be better to use OOP, but this allows page to cache the results.
  def participation_for(entity)
    entity.is_a?(User) ? participation_for_user(entity) : participation_for_group(entity)
  end

  protected

  before_save :ensure_owner
  def ensure_owner
    if Conf.ensure_page_owner?
      if owner_id
        ## do nothing!
      elsif gp = group_participations.detect{|gp|gp.access == ACCESS[:admin]}
        self.owner = gp.group
      elsif self.created_by
        self.owner = self.created_by
      else
        # in real life, we should not get here. but in tests, we make pages a lot
        # that don't have a group or user.
      end
    end
    return true
  end

  ##
  ## DENORMALIZATION
  ##

  protected

  # denormalize hack follows:
  before_save :denormalize
  def denormalize
    if updated_by_id_changed?
      self.updated_by_login = (updated_by.login if updated_by)
    end
    true
  end

  public

  # used to mark stuff that has been changed.
  # so that we know we need to update other stuff when saving.
  def dirty(what)
    @dirty ||= {}
    @dirty[what] = true
  end
  def dirty?(what)
    @dirty ||= {}
    @dirty[what]
  end

  ##
  ## MISC. HELPERS
  ##

  public

  # tmp in-memory storage used by views
  def flag
    @flags ||= {}
  end

  # DEPRECATED
  def self.make_a_call(function,options={})
    PageStork.send(function, options)
  end

  def class_display_name
    self.class.class_display_name
  end

  # override this in subclasses…
  def supports_attachments
    true
  end

  protected

  def save_timestamps
    self.created_at = self.updated_at = Time.now if self.new_record?
  end
end
