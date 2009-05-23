=begin

PAGE.RB

A Page is the main content class. All actual content is a subclass of this class.

denormalization:
all the relationship between a page and its groups is stored in the group_participations table. however, we denormalize some of it: group_name and group_id are used to store the info for the 'primary group'. what does this mean? the primary group is what is show when listing pages and it is the default group when linking from a wiki.

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
    t.integer  "group_id",           :limit => 11
    t.string   "group_name"
    t.string   "updated_by_login"
    t.string   "created_by_login"
    t.integer  "flow",               :limit => 11
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "static"
    t.datetime "static_expires"
    t.boolean  "static_expired"
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
  end

  add_index "pages", ["name"], :name => "index_pages_on_name"
  add_index "pages", ["created_by_id"], :name => "index_page_created_by_id"
  add_index "pages", ["updated_by_id"], :name => "index_page_updated_by_id"
  add_index "pages", ["group_id"], :name => "index_page_group_id"
  add_index "pages", ["type"], :name => "index_pages_on_type"
  add_index "pages", ["flow"], :name => "index_pages_on_flow"
  add_index "pages", ["public"], :name => "index_pages_on_public"
  add_index "pages", ["resolved"], :name => "index_pages_on_resolved"
  add_index "pages", ["created_at"], :name => "index_pages_on_created_at"
  add_index "pages", ["updated_at"], :name => "index_pages_on_updated_at"
  add_index "pages", ["starts_at"], :name => "index_pages_on_starts_at"
  add_index "pages", ["ends_at"], :name => "index_pages_on_ends_at"
  execute "CREATE INDEX owner_name_4 ON pages (owner_name(4))"

  Yeah, so, there are way too many indices on the pages table.
=end

class Page < ActiveRecord::Base
  extend PathFinder::FindByPath
  include PageExtension::Users
  include PageExtension::Groups
  include PageExtension::Create
  include PageExtension::Subclass
  include PageExtension::Index
#  include PageExtension::Linking
  include PageExtension::Static

  acts_as_taggable_on :tags
  acts_as_site_limited
  attr_protected :owner

  ##
  ## PAGE NAMING
  ##

  def validate
    if (name_changed? or group_id_changed?) and name_taken?
      errors.add 'name', 'is already taken'
    elsif name_changed?
      errors.add 'name', 'name is invalid' if name != name.nameize
    end
  end

  def name_url
    name.any? ? name : friendly_url
  end

  def flow= flow
    if flow.kind_of? Integer
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
   return [group_name, name_url].path if group_name
   return [created_by_login, friendly_url].path if created_by_login
   return ['page', friendly_url].path
  end

  # returns true if self's unique page name is already in use.
  # what pages are in the namespace? all pages connected to all
  # groups connected to this page (include the group's committees too).
  def name_taken?
    return false unless self.name.any?
    p = Page.find(:first,
      :conditions => ['pages.name = ? and group_participations.group_id IN (?)', self.name, self.namespace_group_ids],
      :include => :group_participations
    )
    return false if p.nil?
    return self != p
  end

  ##
  ## RELATIONSHIP TO PAGE DATA
  ##

  belongs_to :data, :polymorphic => true, :dependent => :destroy
  has_one :discussion, :dependent => :destroy
  has_many :assets, :dependent => :destroy

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
      self.posts_count = self.discussion.posts_count
    end
  end

  # sets the default media flags. can be overridden by the subclasses.
  before_save :update_media_flags
  def update_media_flags
    if self.data
      self.is_image = self.data.is_image? if self.data.respond_to?('is_image?')
      self.is_audio = self.data.is_audio? if self.data.respond_to?('is_audio?')
      self.is_video = self.data.is_video? if self.data.respond_to?('is_video?')
      self.is_document = self.data.is_document? if self.data.respond_to?('is_document?')
    end
    true
  end
  
  ##
  ## PAGE ACCESS CONTROL
  ##

  ## update attachment permissions
  after_save :update_access
  def update_access
    if public_changed?
      assets.each { |asset| asset.update_access }
    end
    true
  end

  # returns true if self is part of given network
  # DEPRECATED
  # -- TODO
  #   i don't think this does what it is supposed to do.
  #   this code would be better:
  #     self.group_ids.any_in?(network.group_ids + [network.id])
  #   this does a big intersection, slow but not that slow on the limited size of the arrays.
  #   -elijah
  # --
  def belongs_to_network?(network)
    groups = self.groups_with_access(:view)
    groups | self.groups_with_access(:edit)
    groups | self.groups_with_access(:admin)
    groups | self.groups_with_access(:comment)

    groups.include?(network) ? true : false
    true
  end

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
  # DEPRECATED permissions:
  #   :comment -- sometimes viewers can comment and sometimes only participates can.
  #   :delete  -- can user destroy page?
  #  
  # DEPRECATED BEHAVIOR:
  # :edit and :comment should return false for deleted pages.
  #
  def has_access!(perm, user)

    ########################################################
    ## THESE ARE TEMPORARY HACKS...
    ## until the new permission system is working.
    ## then, this logic should all be moved there. 
    return false if tmp_hack_for_deleted_pages?(perm)
    return tmp_hack_when_access_is_delete(user) if perm == :delete
    perm = tmp_hack_for_comment() if perm == :comment
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

  protected

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

  # this is some really horrible stuff that i want to go away very quickly.
  # some sites want to restrict page deletion to only people who are admins
  # of groups that have admin access to the page. crabgrass does not work this
  # way and is a total violation of the permission logic. there is a better way,
  # and it should be replaced for this.
  #
  # this is a unicef specific hack. Group coordinators should be able
  # to delete and move pages in their group independently of the groups
  # access rights.
  def tmp_hack_when_access_is_delete(user)
    parts = []
    parts << participation_for_user(user)
    parts.concat participation_for_groups(user.admin_for_group_ids)
    hacky_delete = parts.compact.detect{|part| part.access == ACCESS[:admin]}
    hacky_delete || has_access!(:admin, user)
  end

  # do not allow comments or editing of deleted pages:
  def tmp_hack_for_deleted_pages?(perm)
    self.deleted? and (perm == :edit or perm == :comment)
  end

  # by default, if a user can edit the page, they can comment.
  # this can be overridden by subclasses.
  def tmp_hack_for_comment
    :view
  end

  public

  ##
  ## RELATIONSHIP TO ENTITIES (GROUPS OR USERS)
  ##

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
      entity = User.find_by_login(entity) || Group.find_by_name(entity)
    end
    raise ArgumentError.new("cannot set page.owner to nil") if entity.nil?

    self.owner_id = entity.id
    self.owner_name = entity.name
    if entity.is_a? Group
      self.owner_type = "Group"
      self.group_name = self.owner_name
      self.group_id = self.owner_id
    elsif entity.is_a? User
      self.owner_type = "User"
    else
      raise Exception.new('must be user or group')
    end
    part = most_privileged_participation_for(entity)
    self.add(entity, :access => :admin) unless part and part.access == ACCESS[:admin]
    return self.owner(true)
  end

  before_create :ensure_owner
  def ensure_owner
    if owner
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

  # a list of people and groups that have admin access to this page
  def admins
    # sometimes the owner is not in the list, this is a grave error, but
    # we ensure that the owner is included in the list of admins.
    groups = group_participations.select{|p|p.access_sym == :admin}.collect{|p|p.group}
    users = user_participations.select{|p|p.access_sym == :admin}.collect{|p|p.user}
    if owner
      groups.unshift(owner) if owner.is_a? Group and !groups.include?(owner)
      users.unshift(owner) if owner.is_a? User and !users.include?(owner)
    end
    return groups + users
  end

  ##
  ## DENORMALIZATION
  ##

  # denormalize hack follows:
  before_save :denormalize
  def denormalize
    if self.owner_type != "Group" and self.group_name.empty? and group_participations.any?
      group = group_participations.first.group
      self.group_name = group.name
      self.group_id = group.id
    end
    if updated_by_id_changed?
      self.updated_by_login = (updated_by.login if updated_by)
    end
    true
  end

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

  # tmp in-memory storage used by views
  def flag
    @flags ||= {}
  end

  def self.make(function,options={})
    PageStork.send(function, options)
  end

  def class_display_name
    self.class.class_display_name
  end

  # override this in subclasses…
  def supports_attachments
    true
  end

end
