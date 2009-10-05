module Groups::BasePermission
  def may_create_group?(parent = @group)
    current_user.superadmin?
  end

  def may_create_network?
    current_user.superadmin?
  end
end
