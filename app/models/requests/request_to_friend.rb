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

  def validate_on_create
    if Friendship.find_by_user_id_and_contact_id(created_by_id, recipient_id)
      errors.add_to_base('Friendship already exists')
    end
    if RequestToFriend.having_state(state).find_by_created_by_id_and_recipient_id(created_by_id, recipient_id)
      errors.add_to_base(I18n.t(:request_exists_error, :recipient => recipient.name))
    end
  end

  def requestable_required?() false end

  def may_create?(user)
    true
  end

  def may_destroy?(user)
    user == recipient or user == created_by
  end

  def may_approve?(user)
    recipient == user
  end

  def may_view?(user)
    user == recipient or may_approve?(user)
  end


  def after_approval
    recipient.add_contact!(created_by, :friend)
  end

  def description
    I18n.t(:request_to_friend_description, :user => user_span(created_by), :other_user => user_span(recipient))
  end

end
