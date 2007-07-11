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
  acts_as_modified
  acts_as_taggable
  #acts_as_ferret :additional_fields => []
  
  tz_time_attributes :created_at, :updated_at, :happens_at

  # to be set by subclasses (ie tools)
  class_attribute :controller, :model, :icon, :internal?,
    :class_description, :class_display_name, :class_group

  ### associations ###  
  
  belongs_to :data, :polymorphic => true
  has_one :discussion, :dependent => :destroy
  has_many :assets, :dependent => :destroy
  
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
  def participation_for_group(group)
    group_participations.detect{|gpart| gpart.group_id == group.id}
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

  def validate
    if name_modified? and name_taken?
      errors.add 'name', 'is already taken'
    end
  end
    
  ### accessors ###
  
  def name_url
    name.any? ? name : friendly_url
  end
  
  def friendly_url
    s = title.nameize
    s = s[0..40].sub(/-([^-])*$/,'') if s.length > 42     # limit name length, and remove any half-cut trailing word
    "#{s}+#{id}"
  end
  
  # lets us convert from a url pretty name to the actual class.
  def self.display_name_to_class(display_name)
    dn = display_name.nameize
    TOOLS.detect{|t|t.class_display_name.nameize == dn if t.class_display_name}
  end 
  # return an array of page classes that are members of class_group
  def self.class_group_to_class_names(class_group)
    TOOLS.collect{|t|t.to_s if t.class_group == class_group and t.class_group}.compact
  end 
  
  ### callbacks ###

  def before_create
    if User.current
      self.created_by = User.current
      self.created_by_login = self.created_by.login
      self.updated_by       = self.created_by
      self.updated_by_login = self.created_by.login
    end
    self.type = self.class.to_s
    # ^^^^^ to work around bug in rails with namespaced
    # models. see http://dev.rubyonrails.org/ticket/7630
    true
  end
 
  def before_save
    # denormalize hack follows:
    if changed? :groups 
      # we use group_participations because self.groups might not
      # reflect current data if unsaved.
      group = (group_participations.first.group if group_participations.any?)
      self.group_name = (group.name if group)
      self.group_id = (group.id if group)
    end
    if changed? :updated_by
      self.updated_by_login = updated_by.login
    end
    true
  end

  after_save :update_access
  def update_access
    assets.each { |asset| asset.update_access }
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
    attributes[:access] = ACCESS[attributes[:access]] if attributes[:access]
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

  # When getting a list of ids of groups for this page,
  # we use group_participations. This way, we will have
  # current data even if a group is added and the page
  # has not yet been saved.
  # used extensively, and by ferret.
  def group_ids
    group_participations.collect{|gpart|gpart.group_id}
  end
  
  # used for ferret index
  def user_ids
    user_participations.collect{|upart|upart.user_id}
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

  # returns an array of group ids that compose this page's namespace
  # includes direct groups and all the relatives of the direct groups.
  def namespace_group_ids
    Group.namespace_ids(group_ids)
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
