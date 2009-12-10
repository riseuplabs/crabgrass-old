module Admin::UsersPermission
  def may_create_users?
    current_user.may?(:admin, current_site)
  end

  alias_method :may_new_users?, :may_create_users?
end
