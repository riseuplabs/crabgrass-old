#
# user to group relationship
# created_at (datetime) -- 
#

class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :page
end

