#
# A Link holds the data representing a connection from one page to another thing.
# Currently, the other thing is limited to a Page or an Asset.
#
# Links are directional: always FROM the parent, and TO the child.
#



#      disabled for now

class Link < ActiveRecord::Base
#  belongs_to :parent, :class_name => 'Page'
#  belongs_to :child, :polymorphic => true
#  acts_as_list :scope => :parent
end

#=end
