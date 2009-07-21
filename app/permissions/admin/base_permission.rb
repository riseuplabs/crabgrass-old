module Admin::BasePermission
  def may_index_admin?
    current_site.id and may_admin_site?
  end
end
