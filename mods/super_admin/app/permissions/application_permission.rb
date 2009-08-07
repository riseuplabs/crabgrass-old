module ApplicationPermission

  def may_admin_site_with_superadmin?
    logged_in? && current_user.superadmin? or
    session[:admin] or
    may_admin_site_without_superadmin?
  end
  alias_method_chain :may_admin_site?, :superadmin

end
