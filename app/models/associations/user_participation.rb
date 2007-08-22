#
# a UserParticipation holds the data representing a user's
# relationship with a particular node.
# 
# fields:
# messages.length (integer) -- the cached count of the user's messages in this node.
# read_at (date) -- the last time the user viewed the node. 
# watch (boolean)   -- flagged to be watched by user? 
# resolved (boolean) -- the user's involvement with this node has been resolved.  
# view_only (boolean) -- the user's participation is limited to viewing.
#

class UserParticipation < ActiveRecord::Base
  belongs_to :page
  belongs_to :user
#  has_many :messages
end
