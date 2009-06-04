module ContactPermission 
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
  def may_create_contact?(user=@user)
    logged_in? and
    user.profiles.visible_by(current_user).may_request_contact?
  end

  alias_method :may_add_contact?, :may_create_contact?

  def may_remove_contact?(user=@user)
    return false unless logged_in? and user
    return true if current_user.friend_of?(user)
    @error_message = 'You are not the contact of %s.'[:not_contact_of] % @user.name
    return false
  end

  def may_approve_contact?(user=@user)
    logged_in? and @past_request.any?
  end

  def may_already_friends_contact?(user=@user)
    logged_in?
  end
end
