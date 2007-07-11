#
# user to group relationship
# created_at (datetime) -- 
#

class Membership < ActiveRecord::Base
  tz_time_attributes :created_at
  belongs_to :user
  belongs_to :group
  belongs_to :page
end

