module RequestsPermission

  def may_create_join_requests?(group=@group)
    logged_in? and
    group.profiles.visible_by(current_user).may_request_membership?
  end

  def may_create_invite_requests?(group=@group)
    logged_in? and
    current_user.may?(:admin, @group)
  end

  def may_list_requests?(group=@group)
    logged_in? and
    current_user.may?(:admin, @group);
  end

  def may_update_requests?(req=@request)
    logged_in? and
    req.may_approve?(current_user)
  end

  %w(approve reject).each{ |action|
    alias_method "may_#{action}_requests?".to_sym, :may_update_requests?
  }

  def may_redeem_requests?(req=@request)
    logged_in?
  end

  def may_destroy_requests?(req=@request)
    logged_in? and
    req.may_destroy?(current_user)
  end

end
