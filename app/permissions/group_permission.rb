module GroupPermission

  def may_read?(group = @group)
    may_see_private?(group) or may_see_public?(group)
  end

  %w(show members search discussions archive tags tasks search).each{ |action|
    alias_method "may_#{action}?".to_sym, :may_read?
  }

  def may_admin?(group = @group)
    logged_in? and current_user.may?(:admin, group)
  end

  %w(update edit_tools edit_layout edit edit_featured_content feature_content edit).each{ |action|
    alias_method "may_#{action}?".to_sym, :may_admin?
  }

  def may_destroy?(group = @group)
    may_admin? and
    ( (group.network? and group.groups.size == 1) or group.users.uniq.size == 1)
  end

  def may_leave?(group = @group)
    logged_in? and
    current_user.direct_member_of?(group) and
    (group.network? or group.users.uniq.size > 1)
  end

  def may_request_membership?(group = @group)
   group.profiles.visible_by(current_user).may_request_membership?
  end

  def may_see_private?(group = @group)
    logged_in? and (current_user.member_of?(group) or current_user.member_of?(group.parent_id))
  end

  def may_see_public?(group = @group)
    group.profiles.public.may_see?
  end

  def may_see_members?(group = @group)
    if logged_in?
      may_admin? || group_member?(group) || group.profiles.visible_by(current_user).may_see_members?
    else
      group.profiles.public.may_see_members?
    end
  end

#  def may_see_committees?(group = @group)
#    return if group.committee?
#    if logged_in?
#      group_member?(group) || group.profiles.visible_by(current_user).may_see_committees?
#    else
#      group.profiles.public.may_see_committees?
#    end
#  end

  def may_see_networks?(group = @group)
    if logged_in?
      group_member?(group) || group.profiles.visible_by(current_user).may_see_members?
    else
      group.profiles.public.may_see_members?
    end
  end

  def may_edit_site_appearance?(group = @group)
    logged_in? and current_site.council == group and current_user.may?(:admin, current_site)
  end
end
