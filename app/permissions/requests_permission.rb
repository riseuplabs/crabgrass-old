module RequestsPermission

  def may_create_join_requests?(group=@group)
   group.profiles.visible_by(current_user).may_request_membership?
  end

  def may_create_invite_requests?(group=@group)
    current_user.may?(:admin, @group)
  end

  def may_read_requests?(group=@group)
    current_user.may?(:admin, @group);
  end

  %w(list).each{ |action|
    alias_method "may_#{action}_requests?".to_sym, :may_read_requests?
  }

  def may_update_requests?(req=@request)
    req.may_approve?(current_user)
  end

  %w(approve reject).each{ |action|
    alias_method "may_#{action}_requests?".to_sym, :may_update_requests?
  }

  def may_redeem_requests?(req=@request)
    true
  end

  def may_destroy_requests?(req=@request)
    req.may_destroy?(current_user)
  end

end
