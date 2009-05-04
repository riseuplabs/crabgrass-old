module GroupPermission
  def may_read(group = @group)
    group.is_publicly_visible? || (logged_in? && current_user.member_of?(@group))
  end

  alias_method :may_show, :may_read
end