# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    current_user.member_of?(@group)
#  end
module VisualizePermission
  def may_show_visualize?(group=@group)
    logged_in? and current_user.member_of?(group)
  end
end
