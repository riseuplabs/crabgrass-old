#
# user to group relationship
#
# created_at (datetime) -- 
#

class Membership < ActiveRecord::Base

  belongs_to :user
  belongs_to :group
  belongs_to :page
  
  # in case someone calls membership.destroy directly
  def after_destroy
    user.clear_peer_cache_of_my_peers
    user.update_membership_cache
    group.increment!(:version)
    true
  end
  
end

