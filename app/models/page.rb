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

#require 'page_tool'

class Page < ActiveRecord::Base
  
  ### associations ###
 
  ## tools used on this page
  #has_many_polymorphs :tools, :through => :page_tools, :from => [:discussions]
  ## this magically creates "has_many :discussions"
  
  ## single tool for this page
  belongs_to :tool, :polymorphic => true
  
  has_one :discussion
  
  # relationship of this page to users
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
  has_many :user_participations
  has_many :users, :through => :user_participations

  # relationship of this page to groups
  has_many :group_participations
  has_many :groups, :through => :group_participations

  # reciprocal links between pages
  has_and_belongs_to_many :pages,
    :class_name => "Page",
    :join_table => "links",
    :association_foreign_key => "other_page_id",
    :foreign_key => "page_id",
    :uniq => true,
    :after_add => :reciprocate_add,
    :after_remove => :reciprocate_remove

  ### validations ###
  
  validates_presence_of :title
  
  ## added for tagging. jb
  acts_as_taggable


  ### callbacks ###

  def before_create
    self.created_by = User.current if User.current
    self.controller = find_controller
    true
  end
 
  def before_save
    self.updated_by = User.current if User.current
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
    entity.add_page(self,attributes)
    self
  end
    
  # remove a group or user participation from this page
  def remove(entity)
    entity.remove_page(self)
  end
  
  # return the page type, in underscore form, without module name.
  #def type
  #  return  if tool_type
  #  return 'page' # default
  #end
  
  # returns the controller for the tool of this page.
  # the controller name is in lowercase/underscore format.
  # if a controller is not specifically defined for this page, 
  # then we derive the controller from the tool type.
  def find_controller
    return controller if controller
    return 'pages' if tool.nil?
	return tool.controller if tool.respond_to? 'controller'
	return tool.type.to_s.gsub(/^.*::/,'').underscore.pluralize
  end
  
  def self.make(function,options={})
    PageStork.send(function, options)
  end


  
end
