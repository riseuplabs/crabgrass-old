#
# add a user to a group
#

class Actions::AddToGroup < Actions::Base

  def initialize(user,group)
    @uid = user.id
    @gid = group.id
  end
  
  def execute(page)
    group = Group.find_by_id @gid
    user = User.find_by_id @uid
    if group and user and !user.member_of?(group)
      group.memberships.create :user => user, :group => group, :page => page
    end
  end
  
end
