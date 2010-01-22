module Groups::MembershipsPermission

  def may_create_memberships?(group=@group)
    logged_in? and
    current_user.may?(:admin, group)
  end

  def may_join_memberships?(group=@group)
    logged_in? and
    (current_user.may?(:admin, group) or group.open_membership?)
  end

  # for now, there is only an edit ui for committees
  def may_edit_memberships?(group=@group)
    may_create_memberships? and group.committee?
  end

  # this seems a little overly complicated
  def may_list_memberships?(group=@group)
    if logged_in?
      current_user.may?(:admin, group) or
      current_user.member_of?(group) or
      group.profiles.visible_by(current_user).may_see_members? or
      (group.committee? && may_list_memberships?(group.parent))
    else
      group.profiles.public.may_see_members?
    end
  end

  # wtf is may_groups_memberships?() for?
  %w(groups).each{ |action|
    alias_method "may_#{action}_memberships?".to_sym, :may_list_memberships?
  }

  def may_update_memberships?(group=@group)
    current_user.may?(:admin, group) and group.committee?
  end

  def may_leave_memberships?(group = @group)
    logged_in? and
    current_user.direct_member_of?(group) and
    (group.network? or group.users.uniq.size > 1)
  end

  def may_destroy_memberships?(membership = @membership)
    group = membership.group

    # has to have a council
    group.council != group and
    current_user.may?(:admin, group)
  end

end
