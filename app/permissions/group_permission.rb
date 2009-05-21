module GroupPermission
  def may_read(group = @group)
    group.is_publicly_visible? || (logged_in? && current_user.member_of?(@group))
  end
  %w(show members search discussions archive tags tasks search).each{|action| alias_method "may_#{action}".to_sym, :may_admin}

  def may_admin(group = @group)
    logged_in? && current_user.may?(:admin, @group)
  end
  %w(update edit_tools edit_layout).each{|action| alias_method "may_#{action}".to_sym, :may_admin}
end