module ApplicationPermission

  def may_admin_site?
    logged_in? and current_user.may?(:admin, current_site)
  end

end
