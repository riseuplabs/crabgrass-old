module Admin::BasePermission
  def may_index_base?
    current_user.may?(:admin, current_site)
  end
end
