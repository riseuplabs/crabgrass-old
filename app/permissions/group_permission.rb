module GroupPermission

  def may_create_group?(parent = nil)
    logged_in? and parent.nil? || may_admin_group?(parent)
  end

  alias_method :may_create_groups?, :may_create_group?  # to be used from the groups controller.
  alias_method :may_create_networks?, :may_create_group?  # to be used from the networks controller.

  def may_show_group?(group = @group)
    may_see_private?(group) or may_see_public?(group)
  end

  %w(members search discussions archive tags tasks trash search view).each{ |action|
    alias_method "may_#{action}_group?".to_sym, :may_show_group?
  }

  def may_update_group?(group = @group)
    logged_in? and current_user.may?(:admin, group)
  end

  %w(admin edit_tools edit_layout edit_cover_media edit edit_featured_content feature_content edit update_trash).each{ |action|
    alias_method "may_#{action}_group?".to_sym, :may_update_group?
  }

  def may_destroy_group?(group = @group)
    may_admin_group? and
    ( (group.network? and group.groups.size == 1) or group.users.uniq.size == 1)
  end

  def may_see_private?(group = @group)
    logged_in? and (current_user.member_of?(group) or current_user.member_of?(group.parent_id))
  end

  def may_see_public?(group = @group)
    group.profiles.public.may_see?
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
