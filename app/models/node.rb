
class Node < ActiveRecord::Base
  
  ### associations ###
  
  has_many :user_participations
  has_many :users,
    :through => 'user_participations'

  has_many :group_participations
  has_many :groups,
    :through => 'group_participations'

  has_and_belongs_to_many :nodes,
    :class_name => "Node",
    :join_table => "links",
    :association_foreign_key => "other_node_id",
    :foreign_key => "node_id",
    :after_add => :reciprocate_add,
    :after_remove => :reciprocate_remove

  belongs_to :tool, :polymophic => true
  
  belongs_to :created_by, 
    :class_name => 'User'
    
  belongs_to :updated_by, 
    :class_name => 'User'
 
  ### callbacks ###
  
  before_create do
    self.created_by = User.current if User.current
  end
 
  before_save do
    self.updated_by = User.current if User.current
  end
  
  def reciprocate_add(other_node)
    other_node.nodes << self unless other_node.nodes.include?(self)
  end
  
  def reciprocate_remove(other_node)
    other_node.nodes.delete(self) rescue nil
  end

end
