#
# user to group relationship
#
# created_at (datetime) -- 
#

class Membership < ActiveRecord::Base

  belongs_to :user
  belongs_to :group
  belongs_to :page
  
  after_destroy :update_user_cache
  
  def update_user_cache
    user.update_membership_cache
  end
  
end

