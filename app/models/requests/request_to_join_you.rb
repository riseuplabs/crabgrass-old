#
# An outside user requests to join a group they are not part of. 
#
# recipient: the group
# requestable: the group
# created_by: person who wants in
#
class RequestToJoinYou < Request
  
  validates_format_of :requestable_type, :with => /Group|Committee|Network/
  validates_format_of :recipient_type, :with => /Group|Committee|Network/

  def group() requestable end

  def may_create?(user)
    created_by == user
  end

  def may_approve?(user)
    user.may?(:admin,group)
  end

  def may_view?(user)
    may_create?(user) or may_approve?(user)
  end

  def after_approval
    group.memberships.create :user => created_by, :group => group
  end

end

