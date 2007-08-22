# == Schema Information
# Schema version: 24
#
# Table name: groups
#
#  id             :integer(11)   not null, primary key
#  name           :string(255)   
#  summary        :string(255)   
#  url            :string(255)   
#  type           :string(255)   
#  parent_id      :integer(11)   
#  admin_group_id :integer(11)   
#  council        :boolean(1)    
#  created_at     :datetime      
#  updated_at     :datetime      
#  avatar_id      :integer(11)   


#  group.name       => string
#  group.summary    => string
#  group.url        => string
#  group.council    => boolean
#  group.created_on => date
#  group.updated_on => time
#  group.children   => groups
#  group.parent     => group
#  group.admin_group  => nil or group
#  group.nodes      => nodes
#  group.users      => users
#  group.picture    => picture


class Group < ActiveRecord::Base

  #track_changes :name
  acts_as_modified
  
  has_one :admin_group, :class_name => 'Group', :foreign_key => 'admin_group_id'

  has_many :memberships, :dependent => :delete_all
  has_many :users, :through => :memberships
  #has_and_belongs_to_many :users, :join_table => :memberships

  # relationship to pages
  has_many :participations, :class_name => 'GroupParticipation', :dependent => :delete_all
  has_many :pages, :through => :participations do
    def pending
      find(:all, :conditions => ['resolved = ?',false], :order => 'happens_at' )
    end
  end

  belongs_to :avatar
  belongs_to :public_home, :class_name => 'Wiki', :foreign_key => 'public_home_id'
  belongs_to :private_home, :class_name => 'Wiki', :foreign_key => 'private_home_id'
  
  has_many :tags, :finder_sql => %q[
    SELECT DISTINCT tags.* FROM tags INNER JOIN taggings ON tags.id = taggings.tag_id
    WHERE taggings.taggable_type = 'Page' AND taggings.taggable_id IN
      (SELECT pages.id FROM pages INNER JOIN group_participations ON pages.id = group_participations.page_id
      WHERE group_participations.group_id = #{id})]
      
#  has_many :federations
#  has_many :networks, :through => :federations

  # committees are children! they must respect their parent group.  
  acts_as_tree :order => 'name'
  alias :committees :children
  
  def user_ids
    @user_ids ||= memberships.collect{|m|m.user_id}
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
    Group.connection.select_values("SELECT groups.id FROM groups WHERE parent_id IN (#{ids})").collect{|id|id.to_i}
  end
    
  # returns a list of group ids for the page namespace
  # (of the group_ids passed in).
  # wtf does this mean? for each group id, we get the ids
  # of all its relatives (parents, children, siblings).
  def self.namespace_ids(ids)
    ids = [ids] unless ids.instance_of? Array
    return [] unless ids.any?
    ids = ids.join(',')
    parent_ids = Group.connection.select_values("SELECT groups.parent_id FROM groups WHERE groups.id IN (#{ids})").collect{|id|id.to_i}
    return ([ids] + committee_ids(ids) + parent_ids + committee_ids(parent_ids)).flatten.uniq
  end
  
#  has_and_belongs_to_many :locations,
#    :class_name => 'Category'
#  has_and_belongs_to_many :categories
 
  ####################################################################### 
  # validations
  
  validates_handle :name
  before_validation_on_create :clean_name
  
  def clean_name
    write_attribute(:name, read_attribute(:name).downcase)
  end
  
  #######################################################################
  # methods

  # the code shouldn't call find_by_name directly, because the group name
  # might contain a space in it, which we store in the database as a plus.
  def self.get_by_name(name)
    return nil unless name
    Group.find_by_name(name.gsub(' ','+'))
  end
  
  def add_page(page, attributes)
    page.group_participations.create attributes.merge(:page_id => page.id, :group_id => id)
    page.changed :groups
  end

  def remove_page(page)
    page.groups.delete(self)
    page.changed :groups
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
    return true if gparts.any?
    raise PermissionDenied
  end
   
  def to_param
    return name
  end
  
  def display_name
    full_name.any? ? full_name : name
  end
  
  def short_name
    name
  end
  
  def banner_style
    @style ||= Style.new(:color => "#eef", :background_color => "#1B5790")
  end
   
  def committee?; instance_of? Committee; end
  def network?; instance_of? Network; end
  def normal?; instance_of? Group; end
  
  
    
  protected
  
  def after_save
    if name_modified?
      update_group_name_of_pages  # update cached group name in pages
      Wiki.clear_all_html(self)   # in case there were links using the old name
      # update all committees (this will also trigger the after_save of committees)
      committees.each {|c| c.update_name } if self.committee?
    end
  end
   
  def update_group_name_of_pages
    Page.connection.execute "UPDATE pages SET `group_name` = '#{self.name}' WHERE pages.group_id = #{self.id}"
  end
    
end
