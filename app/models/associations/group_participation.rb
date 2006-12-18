#
# a GroupParticipation holds the data representing a group's
# relationship with a particular node.
# 
# resolved (boolean) -- the group's involvement with this node has been resolved.  
# view_only (boolean) -- the group's participation is limited to viewing.


class GroupParticipation < ActiveRecord::Base
  belongs_to :page
  belongs_to :group
end
