# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    if !logged_in? or @user.nil?
#      false
#    elsif action?(:destroy, :set_status)
#      current_user == @user
#    else
#      @profile = @user.profiles.visible_by(current_user)
#      @profile.may_see?
#    end
#  end
module MessagesPermission
  def may_show_messages?(user=@user)
    logged_in? and user and
    user.profiles.visible_by(current_user).may_see?
  end

  alias_method :may_index_messages?, :may_show_messages?
  alias_method :may_create_messages?, :may_show_messages?

  def may_destroy_messages?(user=@user)
    logged_in? and user == current_user
  end

  alias_method :may_set_status_messages?, :may_destroy_messages?
end
