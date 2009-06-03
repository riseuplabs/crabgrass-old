module MembershipPermission


  def may_destroy_membership?(group = @group)
    logged_in? and
    current_user.direct_member_of?(group) and
    (group.network? or group.users.uniq.size > 1)
  end

  alias_method :may_leave_membership?, :may_destroy_membership?

end
