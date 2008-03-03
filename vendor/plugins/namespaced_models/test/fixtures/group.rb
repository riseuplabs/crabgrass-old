class Group < ActiveRecord::Base
  has_many :memberships, :class_name => 'Group::Membership'
  has_many :special_memberships, :class_name => 'Group::SpecialMembership'
  
  has_many :people, :through => :memberships
  has_many :special_people, :through => :special_memberships, :source => :person, :class_name => 'Person'
end
