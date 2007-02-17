# == Schema Information
# Schema version: 19
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
#

#
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
  acts_as_tree :order => 'name', :counter_cache => 'true'
  has_one :admin_group, :class_name => 'Group', :foreign_key => 'admin_group_id'

  has_and_belongs_to_many :users, :join_table => :memberships

  # relationship to pages
  has_many :participations, :class_name => 'GroupParticipation'
  has_many :pages, :through => :participations do
	def pending
	  find(:all, :conditions => ['resolved = ?',false], :order => 'happens_at' )
	end
  end

  belongs_to :avatar
  
#  has_many :groups_to_networks
#  has_many :networks,
#    :through => 'groups_to_networks'
  
#  has_many :groups_to_committees
#  has_many :committees,
#    :through => 'groups_to_committees'
  
#  has_and_belongs_to_many :locations,
#    :class_name => 'Category'
#  has_and_belongs_to_many :categories
  
#  belongs_to :picture

  # validations
  
  validates_presence_of :name
  
  
  # methods
  
  def add_page(page, attributes)
    #page.groups << self
    #page.group_participations.pop
    # ^^^ super hack, see note in User.add_page
    #page.group_participations.build attributes.merge(:page_id => page.id, :group_id => id)
    page.group_participations.create attributes.merge(:page_id => page.id, :group_id => id)
  end

  def remove_page(page)
    page.groups.delete(self)
  end
  
end
