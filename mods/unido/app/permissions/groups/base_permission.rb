module Groups::BasePermission
  def may_create_group?(parent = @group)
    may_admin_site?
  end
  alias_method :may_new_group?, :may_create_group?


  def may_create_network?
    may_admin_site?
  end
  alias_method :may_new_network?, :may_create_network?

end
