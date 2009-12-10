module Admin::BasePermission
  def may_index_admin?
    may_admin_site?
  end
end
