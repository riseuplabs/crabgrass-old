module Groups::BasePermission
  def may_create_group?(parent = @group)
    may_admin_site?
  end

  def may_create_network?
    may_admin_site?
  end
end
