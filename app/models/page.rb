=begin

PAGE.RB

A Page is the main content class. All actual content is a subclass of this class.

denormalization:
all the relationship between a page and its groups is stored in the group_participations table. however, we denormalize some of it: group_name and group_id are used to store the info for the 'primary group'. what does this mean? the primary group is what is show when listing pages and it is the default group when linking from a wiki.

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


  #######################################################################
  ## PAGE NAMING
  
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

  #######################################################################
  ## RELATIONSHIP TO PAGE DATA
  
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

  #######################################################################
  ## PAGE ACCESS CONTROL
  
  ## update attachment permissions
  after_save :update_access
  def update_access
    if public_changed?
      assets.each { |asset| asset.update_access }
    end
    true
  end
  
  # This method should never be called directly. It should only be called
  # from User#may?()
  #
  # basic permissions:
  #   :view  -- user can see the page.
  #   :edit  -- user can participate.
  #   :admin -- user can destroy the page, change access.
  # conditional permissions:
  #   :comment -- sometimes viewers can comment and sometimes only participates can.
  #   (NOT SUPPORTED YET)
  #
  # :view should only return true if the user has access to view the page
  # because of participation objects, NOT because the page is public.
  #
  def has_access!(perm, user)
    perm = comment_access if perm == :comment
    upart = self.participation_for_user(user)
    gparts = self.participation_for_groups(user.all_group_ids)
    allowed = false
    if upart or gparts.any?
      parts = []
      parts += gparts if gparts.any?
      parts += [upart] if upart
      part_with_best_access = parts.min {|a,b|
        (a.access||100) <=> (b.access||100)
      }
      # allow :view if the participation exists at all
      allowed = ( part_with_best_access.access || ACCESS[:view] ) <= ACCESS[perm]
    end
    if allowed
      return true
    else
      raise PermissionDenied.new
    end
  end

  # by default, if a user can edit the page, they can comment.
  # this can be overridden by subclasses.
  def comment_access
    :view
  end

  #######################################################################
  ## RELATIONSHIP TO ENTITIES (GROUPS OR USERS)
    
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

  # The owner may be a user or a group.
  def owner=(entity)
    raise ArgumentError.new("owner= can't be nil") if entity.nil?
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
    self.add(entity, :access => :admin) unless entity.may?(:admin, self)
  end

  before_create :ensure_owner
  def ensure_owner
    if gp = self.group_participations.detect{|gp|gp.access == ACCESS[:admin]}
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
  
  #######################################################################
  ## DENORMALIZATION

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

  #######################################################################
  ## MISC. HELPERS

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
