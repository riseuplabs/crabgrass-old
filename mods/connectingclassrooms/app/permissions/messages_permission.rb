module MessagesPermission
  def may_create_messages?(user=@user)
    current_user.groups.any?
  end
end
