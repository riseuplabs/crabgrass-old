
module PublicMessagesPermission
  def may_show_public_messages?(user=@user)
    false
  end

  alias_method :may_index_public_messages?, :may_show_public_messages?

  # no public message posting on cc.net
  def may_create_public_messages?(user=@user)
    false
  end

end

