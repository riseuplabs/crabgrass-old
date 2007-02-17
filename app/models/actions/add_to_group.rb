#
# add a user to a group
#

class Actions::AddToGroup

  def initialize(user,group)
    @uid = user.id
	@gid = group.id
  end
  
  def execute
    group = Group.find @gid
	user = User.find @uid
    user.groups << group
  end
  
end
