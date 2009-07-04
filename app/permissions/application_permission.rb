module ApplicationPermission

  def may_admin_site?
    logged_in? and current_user.may?(:admin, current_site)
  end

  def may_create_private_message?(user=@user)
    user.profile.may_pester?
  end

end
