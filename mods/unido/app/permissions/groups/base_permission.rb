module Groups::BasePermission
  def may_create_group?(parent = @group)
    current_user.super_admin?
  end

  def may_create_network?
    current_user.super_admin?
  end
end
