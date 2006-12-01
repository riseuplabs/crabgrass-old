#
# user to group relationship
# role (string) -- for now, just a title.
#
class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
end
