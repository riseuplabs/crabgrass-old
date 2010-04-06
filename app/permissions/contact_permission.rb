# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    return false unless logged_in?
#    return false unless @user
#
#    if action?(:add)
#      @user.profiles.visible_by(current_user).may_request_contact?
#    elsif action?(:remove)
#      true # current_user.friend_of?(@user) <- we let the action handle the permissions
#    elsif action?(:approve)
#      @past_request.any?
#    elsif action?(:already_friends)
#      true
#    end
#  end
module ContactPermission
  def may_create_contact?(user=@user)
    logged_in? and
    user != current_user and
    user.profiles.visible_by(current_user).may_request_contact?
  end

  alias_method :may_add_contact?, :may_create_contact?

  def may_remove_contact?(user=@user)
    return false unless logged_in? and user
    return true if current_user.friend_of?(user)
    @error_message = I18n.t(:not_contact_of, :user => @user.name)
    return false
  end

  #def may_message_contact?(user=@user)
  #  logged_in? and
  #  user != current_user
  #end

  def may_approve_contact?(user=@user)
    logged_in? and @past_request.any?
  end

  def may_already_friends_contact?(user=@user)
    logged_in?
  end
end
