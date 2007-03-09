#
# add a user to a group
#

class Actions::AddToGroup < Actions::Base

  def initialize(user,group)
    @uid = user.id
	@gid = group.id
  end
  
  def execute
    group = Group.find @gid
	user = User.find @uid
    group.users << user unless group.users.include? user
  end
  
end
