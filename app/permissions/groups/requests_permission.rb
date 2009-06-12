module Groups::RequestsPermission

  def may_create_join_request?(group=@group)
    logged_in? and
    group.profiles.visible_by(current_user).may_request_membership?
  end

  def may_create_invite_request?(group=@group)
    logged_in? and
    current_user.may?(:admin, @group)
  end

  def may_list_requests?(group=@group)
    logged_in? and
    current_user.may?(:admin, @group);
  end

end
