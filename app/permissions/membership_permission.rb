module MembershipPermission

  def may_create_membership?(group=@group)
    return current_user.may?(:admin, @group)
  end

  alias_method :may_join_membership?, :may_create_membership?

  def may_read_membership?(group=@group)
    return current_user.may?(:view_membership, @group)
  end

  %w(list groups).each{ |action|
    alias_method "may_#{action}_membership?".to_sym, :may_read_membership?
  }

  def may_update_membership?(group=@group)
    may_admin_group?(group) and group.committee?
  end

  alias_method :may_edit_membership?, :may_update_membership?

  def may_destroy_membership?(group = @group)
    logged_in? and
    current_user.direct_member_of?(group) and
    (group.network? or group.users.uniq.size > 1)
  end

  alias_method :may_leave_membership?, :may_destroy_membership?

end
