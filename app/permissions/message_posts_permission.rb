module MessagePostsPermission
  def may_create_message_posts(recipient = @recipient)?
    current_user != recipient and recipient.profile.may_pester?
  end
end