module ContactPermission
  # no private messages on cc.net
  def may_message_contact?(user=@user)
    false
  end
end
