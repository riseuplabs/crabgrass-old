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

#  has_many :groups_to_networks
#  has_many :networks,
#    :through => 'groups_to_networks'
  
#  has_many :groups_to_committees
#  has_many :committees,
#    :through => 'groups_to_committees'
  
#  has_many :group_participates
#  has_many :nodes,
#    :through => 'group_participates'

#  has_many :memberships
#  has_many :users, :through => :memberships

  has_and_belongs_to_many :users, :join_table => :memberships
    
#  has_and_belongs_to_many :locations,
#    :class_name => 'Category'
#  has_and_belongs_to_many :categories
  
#  belongs_to :picture

  # validations
  
  validates_presence_of :name
end
