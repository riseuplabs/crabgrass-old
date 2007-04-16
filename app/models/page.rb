# == Schema Information
# Schema version: 24
#
# Table name: pages
#
#  id              :integer(11)   not null, primary key
#  title           :string(255)   
#  created_at      :datetime      
#  updated_at      :datetime      
#  happens_at      :datetime      
#  resolved        :boolean(1)    
#  public          :boolean(1)    
#  needs_attention :boolean(1)    
#  created_by_id   :integer(11)   
#  updated_by_id   :integer(11)   
#  summary         :string(255)   
#  controller      :string(255)   
#  tool_id         :integer(11)   
#  tool_type       :string(255)   
#

# notes
# all the relationship between a page and its groups is stored in the group_participations
# table. however, we denormalize some of it: group_name and group_id are used to store
# the info for the 'primary group'. what does this mean? the primary group is what is 
# show when listing pages and it is the default group when linking from a wiki. 
# 

class Page < ActiveRecord::Base

  # to be set by subclasses (ie tools)
  class_attribute :controller, :model, :icon, :tool_type, :internal?
  
  acts_as_taggable

  ### associations ###  
  
  belongs_to :data, :polymorphic => true
  has_one :discussion, :dependent => :destroy
  
  # relationship of this page to users
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
  has_many :user_participations, :dependent => :destroy
  has_many :users, :through => :user_participations do
    def with_access
      find(:all, :conditions => 'access IS NOT NULL')
    end
    def participated
      find(:all, :conditions => 'changed_at IS NOT NULL')
    end
  end

  # relationship of this page to groups
  has_many :group_participations, :dependent => :destroy
  has_many :groups, :through => :group_participations
  belongs_to :group # the main group
  
  # like users.with_access, but uses already included data
  def users_with_access
    user_participations.collect{|part| part.user if part.access }.compact
  end
  
  # like users.participated, but uses already included data
  def contributors
    user_participations.collect{|part| part.user if part.changed_at }.compact
  end
  
  # like user_participations.find_by_user_id, but uses already included data
  def participation_for_user(user) 
    user_participations.detect{|p| p.user_id==user.id }
  end

  # takes an array of group ids, return all the matching group participations
  # this is called a lot, since it is used to determine permission for the page
  def participation_for_groups(group_ids) 
    group_participations.collect{|gpart| gpart if group_ids.include? gpart.group_id }.compact
  end
  
  
  # adding this in creates "SystemStackError (stack level too deep)"
  # when the page is destroyed in production mode. weird.
  # this bug seems related: http://dev.rubyonrails.org/ticket/4386
  # reciprocal links between pages
#  has_and_belongs_to_many :pages,
#    :class_name => "Page",
#    :join_table => "links",
#    :association_foreign_key => "other_page_id",
#    :foreign_key => "page_id",
#    :uniq => true,
#    :after_add => :reciprocate_add,
#    :after_remove => :reciprocate_remove

  ### validations ###
  
  validates_presence_of :title
  validates_associated :data

  # page name must start with a letter.
  validates_format_of  :name, :with => /^$|^[a-z]+([-_]*[a-z0-9]+){1,39}$/
 
  ### accessors ###
  
  def name_url
    name.any? ? name : friendly_url
  end
  
  def friendly_url
    s = title.nameize
    s = s[0..40].sub(/-([^-])*$/,'') if s.length > 42     # limit name length, and remove any half-cut trailing word
    "#{id}-#{s}"
  end
  
  ### callbacks ###

  def before_create
    self.created_by = User.current if User.current
    self.updated_by = created_by
    self.updated_by_login = updated_by.login if updated_by  # denormalize hack
    self.type = self.class.to_s # to work around bug in rails with namespaced models http://dev.rubyonrails.org/ticket/7630
    true
  end
 
  def before_save
    # denormalize hack follows:
    if changed? :groups 
      # we use group_participations because self.groups might not reflect current data if unsaved.
      group = (group_participations.first.group if group_participations.any?)
      self.group_name = (group.name if group)
      self.group_id = (group.id if group)
    end
    if changed? :updated_by
      self.updated_by_login = updated_by.login
    end
    true
  end
  
  def reciprocate_add(other_page)
    other_page.pages << self unless other_page.pages.include?(self)
  end
  
  def reciprocate_remove(other_page)
    other_page.pages.delete(self) rescue nil
  end

  ### methods ###
    
  # add a group or user participation to this page
  def add(entity, attributes={})
    if entity.is_a? Enumerable
      entity.each do |e|
        e.add_page(self,attributes)
      end
    else
      entity.add_page(self,attributes)
    end
    self
  end
      
  # remove a group or user participation from this page
  def remove(entity)
    if entity.is_a? Enumerable
      entity.each do |e|
        e.remove_page(self)
      end
    else
      entity.remove_page(self)
    end
  end
  
  def unresolve
    resolve(false)
  end
  def resolve(value=true)
    user_participations.each do |up|
      up.resolved = value
      up.save
    end
    resolved = value
    save
  end
  
  def self.make(function,options={})
    PageStork.send(function, options)
  end

  # we use group_participations, because it will have current info
  # even if a group is added before the page is saved.
  def group_ids
    group_participations.collect{|gpart|gpart.group_id}
  end
  
  # the main group is used for linking. we don't yet know what the main
  # group is or how it is specified, but for linking it is very useful to
  # have a default group for links that don't explicitly specify a group.
  # return nil if there are no groups for this page
  # (we use group_participations, because it will have current info
  #  even if a group is added before the page is saved.)
  #def main_group_name
  #  return group_participations.first.group.name if group_participations.any?
  #end
  
  # generates a unique name that is sure to not conflict
  # with any others.
  def find_unique_name(string)
    return nil unless string and group_ids.any?
    newname = string.nameize
    i=nil
    while find_pages_with_name("#{newname}#{i}").any?
      i ||= 0; i += 1
    end
    return "#{newname}#{i}"
  end
  
  # returns a list of pages with a particular name in same "page space" as self.
  # by "page space" we mean all pages in all groups that own this page.
  def find_pages_with_name(pagename)
    Page.find(
      :all,
      :conditions => ['pages.name = ? and group_participations.group_id IN (?)',pagename,self.group_ids],
      :include => :group_participations
    )
  end  

  # used to mark stuff that has been changed.
  # so that we know we need to update other stuff when saving.
  def changed(what)
    @changed ||= {}
    @changed[what] = true
  end
  def changed?(what)
    @changed ||= {}
    @changed[what]
  end
  
end
