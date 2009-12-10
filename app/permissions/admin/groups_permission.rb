module Admin::GroupsPermission
  def may_create_groups?
    current_user.may?(:admin, current_site)
  end

  alias_method :may_new_groups?, :may_create_groups?
end
