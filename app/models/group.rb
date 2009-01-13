=begin
  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "full_name"
    t.string   "summary"
    t.string   "url"
    t.string   "type"
    t.integer  "parent_id"
    t.integer  "council_id"
    t.boolean  "is_council"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "avatar_id"
    t.string   "style"
  end

  associations:
  group.children   => groups
  group.parent     => group
  group.council  => nil or group
  group.users      => users
=end

class Group < ActiveRecord::Base
  attr_accessible :name, :full_name, :short_name, :summary, :language

   # not saved to database, just used by activity feed:
  attr_accessor :created_by, :destroyed_by

  ##
  ## FINDERS
  ## 

  # finds groups that user may see
  named_scope :visible_by, lambda { |user|
    select = 'DISTINCT groups.*'
    # ^^ another way to solve duplicates would be to put profiles.friend = true in other side of OR
    group_ids = user ? Group.namespace_ids(user.all_group_ids) : []
    joins = "LEFT OUTER JOIN profiles ON profiles.entity_id = groups.id AND profiles.entity_type = 'Group'"
    {:select => select, :joins => joins, :conditions => ["(profiles.stranger = ? AND profiles.may_see = ?) OR (groups.id IN (?))", true, true, group_ids]}
  }

  # finds groups that are of type Group (but not Committee or Network)
  named_scope :only_groups, :conditions => 'groups.type IS NULL'

  
  ##
  ## GROUP INFORMATION
  ##

  include CrabgrassDispatcher::Validations
  validates_handle :name
  before_validation :clean_names

  def clean_names
    t_name = read_attribute(:name)
    if t_name
      write_attribute(:name, t_name.downcase)
    end
    
    t_name = read_attribute(:full_name)
    if t_name
      write_attribute(:full_name, t_name.gsub(/[&<>]/,''))
    end
  end

  # the code shouldn't call find_by_name directly, because the group name
  # might contain a space in it, which we store in the database as a plus.
  def self.find_by_name(name)
    return nil unless name.any?
    Group.find(:first, :conditions => ['groups.name = ?', name.gsub(' ','+')])
  end

  belongs_to :avatar
  has_many :profiles, :as => 'entity', :dependent => :destroy, :extend => ProfileMethods
  
  # name stuff
  def to_param; name; end
  def display_name; full_name.any? ? full_name : name; end
  def short_name; name; end
  def cut_name; name[0..20]; end
  def both_names
    return name if name == display_name
    return "%s (%s)" % [display_name, name]
  end

  # visual identity
  def banner_style
    @style ||= Style.new(:color => "#eef", :background_color => "#1B5790")
  end
   
  def committee?; instance_of? Committee; end
  def network?; instance_of? Network; end
  def normal?; instance_of? Group; end  
  def display_type() self.class.to_s.downcase; end
 
  ##
  ## RELATIONSHIPS TO USERS
  ## 

  has_many :memberships, :dependent => :destroy,
    :before_add => :check_duplicate_memberships

  has_many :users, :through => :memberships do
    def <<(*dummy)
      raise Exception.new("don't call << on group.users");
    end
    def delete(*records)
      raise Exception.new("don't call delete on group.users");
    end
  end
  
  def user_ids
    @user_ids ||= memberships.collect{|m|m.user_id}
  end

  def all_users
    users
  end

  # association callback
  def check_duplicate_memberships(membership)
    membership.user.check_duplicate_memberships(membership)
  end

  def relationship_to(user)
    relationships_to(user).first
  end
  def relationships_to(user)
    return [:stranger] unless user
    return [:stranger] if user.is_a? UnauthenticatedUser
    (@relationships ||= {})[user.login] ||= get_relationships_to(user)
  end
  def get_relationships_to(user)
    ret = []
#   ret << :admin    if ...
    ret << :member   if user.member_of?(self)
#   ret << :peer     if ...
    ret << :stranger if ret.empty?
    ret
  end
  
  # this is the ONLY way to add users to a group.
  # all other methods will not work.
  def add_user!(user)
    self.memberships.create! :user => user
    user.update_membership_cache
    user.clear_peer_cache_of_my_peers

    @user_ids = nil
    self.increment!(:version)
  end
  
  # this is the ONLY way to remove users from a group.
  # all other methods will not work.
  def remove_user!(user)
    membership = self.memberships.find_by_user_id(user.id)
    raise ErrorMessage.new('no such membership') unless membership

    user.clear_peer_cache_of_my_peers
    membership.destroy
    user.update_membership_cache

    @user_ids = nil
    self.increment!(:version)
  end
  
# maps a user <-> group relationship to user <-> language
#  def in_user_terms(relationship)
#    case relationship
#      when :member;   'friend'
#      when :ally;     'peer'
#      else; relationship.to_s
#    end  
#  end

  ##
  ## RELATIONSHIP TO ASSOCIATED DATA
  ## 

  after_destroy :destroy_requests
  def destroy_requests
    Request.destroy_for_group(self)
  end


  ####################################################################
  ## permissions
  
  def may_be_pestered_by?(user)
    begin
      may_be_pestered_by!(user)
    rescue PermissionDenied
      false
    end
  end
  
  def may_be_pestered_by!(user)
    if user.member_of?(self) or publicly_visible_group or (parent and parent.publicly_visible_committees and parent.may_be_pestered_by?(user))
      return true
    else
      raise PermissionDenied.new('You are not allowed to share with %s'[:pester_denied] % self.name)
    end
  end

  # if user has +access+ to group, return true.
  # otherwise, raise PermissionDenied
  def has_access!(access, user)
    if access == :admin
      ok = user.member_of?(self.council)
    elsif access == :edit
      ok = user.member_of?(self) || user.member_of?(self.council)
    elsif access == :view
      ok = user.member_of?(self) || profiles.public.may_see?
    elsif access == :view_membership
      ok = user.member_of?(self) || self.has_access!(:admin,user) || profiles.visible_by(user).may_see_members?
    end
    ok or raise PermissionDenied.new
  end

  def has_access?(access, user)
    return has_access!(access, user)
  rescue PermissionDenied
    return false
  end

  ####################################################################
  ## relationship to pages

  # this makes this group's pages featureable
  include GroupExtension::Featured
  
  has_many :participations, :class_name => 'GroupParticipation', :dependent => :delete_all
  has_many :pages, :through => :participations do
    def pending
      find(:all, :conditions => ['resolved = ?',false], :order => 'happens_at' )
    end
  end

  #
  # build or modify a group_participation between a group and a page
  # return the group_participation object, which must be saved for
  # changes to take effect.
  # 
  def add_page(page, attributes)
    participation = page.participation_for_group(self)
    if participation
      participation.attributes = attributes
    else
      participation = page.group_participations.build attributes.merge(:page_id => page.id, :group_id => id)
    end
    page.group_id_will_change!
    page.association_will_change(:groups)
    return participation
  end

  def remove_page(page)
    page.groups.delete(self)
    page.group_id_will_change!
    page.association_will_change(:groups)
    page.group_participations.reset
  end
  
  def may?(perm, page)
    begin
       may!(perm,page)
    rescue PermissionDenied
       false
    end
  end
  
  # perm one of :view, :edit, :admin
  # this is still a basic stub. see User.may!
  def may!(perm, page)
    gparts = page.participation_for_groups(group_and_committee_ids)
    if gparts.any?
      part_with_best_access = gparts.min {|a,b|
        (a.access||100) <=> (b.access||100)
      }
      return ( part_with_best_access.access || ACCESS[:view] ) <= ACCESS[perm]
    else
      raise PermissionDenied.new
    end
  end

  ####################################################################
  ## relationship to other groups

  has_many :federatings
  has_many :networks, :through => :federatings
  belongs_to :council, :class_name => 'Group'

  # Committees are children! They must respect their parent group. 
  # This uses better_acts_as_tree, which allows callbacks.
  acts_as_tree(
    :order => 'name',
    :after_add => :org_structure_changed,
    :after_remove => :org_structure_changed
  )
  alias :committees :children

  # Adds a new committee or makes an existing committee be the council (if
  # the make_council argument is set). No other method of adding committees
  # should be used.
  def add_committee!(committee, make_council=false)
    committee.parent_id = self.id
    committee.parent_name_changed
    if make_council
      if council
        council.update_attribute(:is_council, false)
      end
      self.council = committee
      committee.is_council = true  
    elsif self.council == committee && !make_council
      committee.is_council = false
      self.council = nil
    end
    committee.save!
    self.org_structure_changed
    self.save!
    self.committees.reset
  end

  # Removes a committee. No other method should be used.
  def remove_committee!(committee)
    committee.parent_id = nil
    if council_id == committee.id
      self.council_id = nil
      committee.is_council = false
    end
    committee.save!
    self.org_structure_changed
    self.save!
    self.committees.reset
  end

  # returns an array of all children ids and self id (but not parents).
  # this is used to determine if a group has access to a page.
  def group_and_committee_ids
    @group_ids ||= ([self.id] + Group.committee_ids(self.id))
  end
  
  # returns an array of committee ids given an array of group ids.
  def self.committee_ids(ids)
    ids = [ids] unless ids.instance_of? Array
    return [] unless ids.any?
    ids = ids.join(',')
    Group.connection.select_values(
      "SELECT groups.id FROM groups WHERE parent_id IN (#{ids})"
    ).collect{|id|id.to_i}
  end
  
  def self.parent_ids(ids)
    ids = [ids] unless ids.instance_of? Array
    return [] unless ids.any?
    ids = ids.join(',')
    Group.connection.select_values(
      "SELECT groups.parent_id FROM groups WHERE groups.id IN (#{ids})"
    ).collect{|id|id.to_i}
  end

  # returns an array of committees visible to appropriate access level
  def committees_for(access)
    if access == :private
      return self.committees
    elsif access == :public
      if profiles.public.may_see_committees?
        return @comittees_for_public ||= self.committees.select {|c| c.profiles.public.may_see?}
      else
        return []
      end
    end
  end
    
  # Returns a list of group ids for the page namespace of every group id
  # passed in. wtf does this mean? for each group id, we get the ids
  # of all its relatives (parents, children, siblings).
  def self.namespace_ids(ids)
    ids = [ids] unless ids.is_a? Array
    return [] unless ids.any?
    parentids = parent_ids(ids)
    return (ids + parentids + committee_ids(ids+parentids)).flatten.uniq
  end

  # whenever the structure of this group has changed 
  # (ie a committee or network has been added or removed)
  # this function should be called. Afterward, a save is required.
  def org_structure_changed(child=nil)
    User.clear_membership_cache(user_ids)
    self.version += 1
  end

  alias_method :real_council, :council
  def council(reload=false)
    real_council(reload) || self
  end

  # overridden for Networks
  def groups() [] end
  
  ######################################################
  ## temp stuff for profile transition
  ## should be removed eventually
    

  def publicly_visible_group
    profiles.public.may_see?
  end
  def publicly_visible_group=(val)
    profiles.public.update_attribute :may_see, val
  end

  def publicly_visible_committees
    profiles.public.may_see_committees?
  end
  def publicly_visible_committees=(val)
    profiles.public.update_attribute :may_see_committees, val
  end

  def publicly_visible_members
    profiles.public.may_see_members?
  end
  def publicly_visible_members=(val)
    profiles.public.update_attribute :may_see_members, val
  end

  def accept_new_membership_requests
    profiles.public.may_request_membership?
  end
  def accept_new_membership_requests=(val)
    profiles.public.update_attribute :may_request_membership, val
  end

  has_one :group_setting
  # can't remember the way to do this automatically
  after_create :create_group_setting
  def create_group_setting
    self.group_setting = GroupSetting.new
    self.group_setting.save
  end
  
  protected
  
  after_save :update_name
  def update_name
    if name_changed?
      update_group_name_of_pages  # update cached group name in pages
      Wiki.clear_all_html(self)   # in case there were links using the old name
      # update all committees (this will also trigger the after_save of committees)
      committees.each {|c| c.parent_name_changed }
      User.increment_version(self.user_ids)
    end
  end
   
  def update_group_name_of_pages
    Page.connection.execute "UPDATE pages SET `group_name` = '#{self.name}' WHERE pages.group_id = #{self.id}"
    Page.connection.execute "UPDATE pages SET `owner_name` = '#{self.name}' WHERE pages.owner_id = #{self.id} AND pages.owner_type = 'Group'"
  end
    
end
