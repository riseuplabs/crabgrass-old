module ApplicationPermission
 # private messages are disabled on cc.net
  def may_create_private_message?(user=@user)
    false
  end
end
