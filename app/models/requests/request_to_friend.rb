#
# A contact request
#
# creator: user wanting a friend
# recipient: potential friend
# requestable: nil
# 
#
class RequestToFriend < Request
  
  validates_format_of :recipient_type, :with => /User/

  def requestable_required?() false end

  def may_create?(user)
    true
  end

  def may_approve?(user)
    recipient == user
  end

  def may_view?(user)
    user == recipient or may_approve?(user)
  end

  def after_approval
    recipient.contacts << created_by
  end

end

