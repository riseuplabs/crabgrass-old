module GroupPermission
  def may_read(group = @group)
    # TODO:
    # This is just a quick fix. check_group_visibility should be moved here.
    # the old destinction between get and post should als be transfered.
    # all the before filters need to be checked if they actually work the
    # way we want.
    check_group_visibility
  end
  %w(show members search discussions archive tags tasks search).each{ |action|
    alias_method "may_#{action}".to_sym, :may_read
  }

  def may_admin(group = @group)
    logged_in? && current_user.may?(:admin, @group)
  end
  %w(update edit_tools edit_layout destroy edit edit_featured_content feature_content).each{ |action|
    alias_method "may_#{action}".to_sym, :may_admin
  }
end
