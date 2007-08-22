# == Schema Information
# Schema version: 24
#
# Table name: users
#
#  id                        :integer(11)   not null, primary key
#  login                     :string(255)   
#  email                     :string(255)   
#  crypted_password          :string(40)    
#  salt                      :string(40)    
#  created_at                :datetime      
#  updated_at                :datetime      
#  remember_token            :string(255)   
#  remember_token_expires_at :datetime      
#  display_name              :string(255)   
#  time_zone                 :string(255)   
#  language                  :string(5)     
#  avatar_id                 :integer(11)   
#

class User < AuthenticatedUser
  ### attributes
  
  # a class attr which is set to the currently logged in user
  cattr_accessor :current
  
  ### associations
 
  # groups we are members of
  has_many :memberships, :dependent => :delete_all
  has_many :groups, :through => :memberships,
    :after_add => :clear_group_id_cache,
    :after_remove => :clear_group_id_cache

#  has_and_belongs_to_many :groups, :join_table => :memberships,
#    :after_add => :clear_group_id_cache,
#    :after_remove => :clear_group_id_cache

  # all groups, including groups we have indirect access to (ie committees and networks)
  has_many :all_groups, :class_name => 'Group', :finder_sql => 'SELECT groups.* FROM groups WHERE groups.id IN (#{ all_group_ids.any? ? all_group_ids.join(",") : "NULL" })'
  
  # peers are users who share at least one group with us
  has_many :peers, :class_name => 'User',
    :finder_sql => 'SELECT DISTINCT users.* FROM users INNER JOIN memberships ON users.id = memberships.user_id WHERE users.id != #{id} AND memberships.group_id IN (SELECT groups.id FROM groups INNER JOIN memberships ON groups.id = memberships.group_id WHERE memberships.user_id = #{id})'
  
  # relationship to pages
  has_many :participations, :class_name => 'UserParticipation'
  has_many :pages, :through => :participations do
    def pending
      find(:all, :conditions => ['resolved = ?',false], :order => 'happens_at' )
    end
  end
  
  belongs_to :avatar
  
  has_many :pages_created, 
    :class_name => "Page", :foreign_key => :created_by_id 

  has_many :pages_updated, 
    :class_name => "Page", :foreign_key => :updated_by_id 

  # relationship to other users
  has_and_belongs_to_many :contacts,
    :class_name => "User",
    :join_table => "contacts",
    :association_foreign_key => "contact_id",
    :foreign_key => "user_id",
    :after_add => :reciprocate_add,
    :after_remove => :reciprocate_remove do
    def online
      find(:all, :conditions => ['users.last_seen_at > ?',10.minutes.ago], :order => 'users.last_seen_at DESC')
    end
  end
  
  has_many :tags, :finder_sql => %q[
    SELECT DISTINCT tags.* FROM tags INNER JOIN taggings ON tags.id = taggings.tag_id
    WHERE taggings.taggable_type = 'Page' AND taggings.taggable_id IN
      (SELECT pages.id FROM pages INNER JOIN user_participations ON pages.id = user_participations.page_id
      WHERE user_participations.user_id = #{id})]
    
  ### validations
  
  validates_format_of :login, :with => /^[a-z0-9]+([-_\.]?[a-z0-9]+){1,17}$/
  before_validation_on_create :clean_login
  
  def clean_login
    write_attribute(:login, read_attribute(:login).downcase)
  end
  
  ### callbacks
 
  def after_destroy
    avatar.destroy if avatar
  end
  
  # if i add you as a contact, then you get
  # me as a contact as well.
  def reciprocate_add(other_user)
    other_user.contacts << self unless other_user.contacts.include?(self)
  end
  
  # if i remove you as a contact, then you 
  # remove me as a contact as well.  
  def reciprocate_remove(other_user)
    other_user.contacts.delete(self) if other_user.contacts.include?(self)
  end
  
  ### public methods
  
  # the user's custom display name, could be anything.
  def display_name
    read_attribute('display_name').any? ? read_attribute('display_name') : login
  end
  
  # the user's handle, in same namespace as group name,
  # must be url safe.
  def name; login; end
  
  # displays both display_name and name
  def both_names
    if read_attribute('display_name').any? and read_attribute('display_name') != name
      '%s (%s)' % [display_name,name]
    else
      name
    end
  end
  
  def to_param
    return login
  end

  def may?(perm, page)
    begin
      return may!(perm,page)
    rescue PermissionDenied
      return false
    end
  end
  
  # basic permissions:
  #   :view or :read -- user can see the page.
  #   :edit or :change -- user can participate.
  #   :admin -- user can destroy the page, change access.
  # conditional permissions:
  #   :comment -- sometimes viewers can comment and sometimes only participates can.
  #
  # this is still a basic stub.
  def may!(perm, page)
    upart = page.participation_for_user(self)
    return true if upart
    gparts = page.participation_for_groups(all_group_ids)
    return true if gparts.any?
    raise PermissionDenied
  end
  
  def add_page(page, attributes)
    return if page.participation_for_user(self) # don't add the page twice

    # user_participations.build doesn't update the pages.users
    # until it is saved, which seems like a bug, so we use create
    page.user_participations.create attributes.merge(
       :page_id => page.id, :user_id => id,
       :resolved => page.resolved?)
    
    # mark users as changed
    page.changed :users
  end
  
  def remove_page(page)
    page.users.delete(self)
    page.changed :users
  end
  
  # should be called when a user visits a page
  # we only update user_participation if it already exists
  def viewed(page)
    part = page.participation_for_user(self)
    return unless part
    part.update_attributes(:viewed_at => Time.now, :viewed => true)
  end
  
  # set resolved status vis-à-vis self.
  def resolved(page, resolved_flag)
    find_or_build_participation(page).update_attributes :resolved => resolved_flag
  end
  
  def find_or_build_participation(page)
    page.participation_for_user(self) || page.user_participations.build(:user_id => self.id) 
  end
  
  # should be called when a user writes to a page
  # or resolves a page.
  # options:
  #  - resolved: user's participation is resolved with this page
  #  - all_resolved: everyone's participation is resolved.
  #
  def updated(page, options={})
    # create self's participation if it does not exist
    find_or_build_participation(page)

    unless page.contributors.include?(self)
      page.contributors_count +=1
    end
     
    # update everyone's participation
    now = Time.now
    page.user_participations.each do |party|
      if party.user_id == self.id
        party.changed_at = now
        party.viewed_at = now
        party.viewed = true
        party.resolved = options[:resolved] || options[:all_resolved] || party.resolved?
      else
        party.resolved = options[:all_resolved] || party.resolved?
        party.viewed = false
      end
      party.save      
    end
    # this is unfortunate, because perhaps we have already just modified the page?
    page.resolved = options[:all_resolved] || page.resolved?
    page.updated_at = now
    page.updated_by = self
    page.changed :updated_by
    page.save
  end
  
  # is this user a member of the group?
  # (or any of the associated groups)
  def member_of?(group)
    if group.is_a? Integer
      return all_group_ids.include?(group)
    elsif group.is_a? Array
      return group.detect{|g| member_of?(g)}
    elsif group
      return all_group_ids.include?(group.id)
    else
      return false
    end
  end
  
  # is the user a direct member of the group?
  def direct_member_of?(group)
    if group.is_a? Integer
      return group_ids.include?(group)
    elsif group.is_a? Array
      return group.detect{|g| direct_member_of?(g)}
    else
      return group_ids.include?(group.id)
    end
  end
  
  def group_ids
    @group_ids ||= memberships.collect{|m|m.group_id}
  end

  # returns an array of the ids of all the groups we have access
  # to. This might include groups we don't have a direct membership
  # in (ie committees or networks of groups we are in.)
  def all_group_ids
    @all_group_ids ||= find_group_ids
  end
  
  def find_group_ids
    mygroups = Group.connection.select_values("SELECT groups.id FROM groups INNER JOIN memberships ON groups.id = memberships.group_id WHERE (memberships.user_id = #{self.id})")
    return [] unless mygroups.any?
    #mycommittees = Group.connection.select_values("SELECT groups.id FROM groups INNER JOIN groups_to_committees ON groups.id = groups_to_committees.committee_id WHERE groups_to_committees.group_id IN (#{mygroups.join(',')}) AND (groups.type = 'Committee')")
    mycommittees = Group.connection.select_values("SELECT groups.id FROM groups WHERE groups.parent_id IN (#{mygroups.join(',')})")
    mynetworks = Group.connection.select_values("SELECT groups.id FROM groups INNER JOIN groups_to_networks ON groups.id = groups_to_networks.network_id WHERE groups_to_networks.group_id IN (#{mygroups.join(',')}) AND (groups.type = 'Network')")
    return (mygroups + mycommittees + mynetworks).collect{|id|id.to_i}.uniq
  end
  
  # called whenever our group membership is changed
  def clear_group_id_cache(group)
    @all_group_ids = nil
    @group_ids = nil
  end
  
  def banner_style
    @style ||= Style.new(:color => "#E2F0C0", :background_color => "#6E901B")
  end
    
  def online?
    last_seen_at > 10.minutes.ago if last_seen_at
  end
  
  def time_zone
    read_attribute(:time_zone) || DEFAULT_TZ
  end
  
end
