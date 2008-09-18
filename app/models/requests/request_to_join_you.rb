#
# An outside user requests to join a group they are not part of. 
#
# recipient: the group
# requestable: not used
# created_by: person who wants in
#
class RequestToJoinYou < Request
  
  validates_format_of :recipient_type, :with => /Group/

  def validate_on_create
    if Membership.find_by_user_id_and_group_id(created_by_id, recipient_id)
      errors.add_to_base('Membership already exists')
    end
    if RequestToJoinYou.find_by_created_by_id_and_recipient_id_and_state(created_by_id, recipient_id, state)
      errors.add_to_base('Request already exists for %s'[:request_exists_error] % recipient.name)
    end
  end

  def requestable_required?() false end

  def group() recipient end

  def may_create?(user)
    created_by == user
  end

  def may_approve?(user)
    user.may?(:admin,group)
  end

  def may_destroy?(user)
    user.may?(:admin, group) or user == created_by
  end

  def may_view?(user)
    may_create?(user) or may_approve?(user)
  end

  def after_approval
    group.memberships.create :user => created_by, :group => group
  end

  def description
    "%s requested to join %s"[:request_to_join_you_description] % [user_span(created_by), group_span(group)]
  end

end

