# == Schema Information
# Schema version: 19
#
# Table name: pages
#
#  id            :integer(11)   not null, primary key
#  title         :string(255)   
#  created_at    :datetime      
#  updated_at    :datetime      
#  happens_at    :datetime      
#  resolved      :boolean(1)    
#  public        :boolean(1)    
#  created_by_id :integer(11)   
#  updated_by_id :integer(11)   
#  tool_id       :integer(11)   
#  tool_type     :string(255)   
#

require 'page_tool'

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

  ### callbacks ###
  
  before_create do
    self.created_by = User.current if User.current
  end
 
  before_save do
    self.updated_by = User.current if User.current
  end
  
  def reciprocate_add(other_page)
    other_page.pages << self unless other_page.pages.include?(self)
  end
  
  def reciprocate_remove(other_page)
    other_page.pages.delete(self) rescue nil
  end

end
