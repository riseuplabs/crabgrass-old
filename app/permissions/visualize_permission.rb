module VisualizePermission
  #  def authorized?
  #    current_user.member_of?(@group)
  #  end
  def may_show_visualize?(group=@group)
    logged_in? and current_user.member_of?(group)
  end
end
