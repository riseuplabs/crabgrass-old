module Groups::RequestsPermission

  def may_create_join_request?(group=@group)
    logged_in? and
    group and
    group.profiles.visible_by(current_user).may_request_membership?
  end

  def may_create_invite_request?(group=@group)
    current_user.may?(:admin, group)
  end

  def may_create_destroy_request?(group=@group)
    # disabled until release 0.5.1
    return false

    # group with council
    if group.council != group and group.council.users.size != 1
      current_user.may?(:admin, group)
    else
      # no council
      group.users.size != 1 and
        current_user.member_of?(group)
    end
  end

  def may_admin_requests?(group=@group)
    current_user.may?(:admin, group)
  end

  alias_method :may_list_requests?, :may_admin_requests?
  alias_method :may_index_requests?, :may_admin_requests?
  alias_method :may_update_requests?, :may_admin_requests?

end
