# a link holds the data representing a connection from one node to another.
# links are bi-directional: creating a link in one direction also triggers the creation of 
# another link object in the other direction.

class Link < ActiveRecord::Base
  belongs_to :node
  belongs_to :other_node,
    :class_name => 'Node'
  
end
