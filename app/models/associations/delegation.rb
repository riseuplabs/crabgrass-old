# A Delegation holds the data relating to an association between a group and committee.

class Delegation < ActiveRecord::Base
  belongs_to :group
  belongs_to :committee
  belongs_to :convener, :class_name => 'User'  
end
