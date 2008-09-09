#
# Otherwise known as a group membership invitation 
#
# recipient: person who may be added to group
# requestable: the group
# created_by: person who sent the invite
#
class RequestToJoinUs < Request
  
  validates_format_of :requestable_type, :with => /Group|Committee|Network/
  validates_format_of :recipient_type, :with => /User/

  def group() requestable end

  def may_create?(user)
    user.may?(:admin,group)
  end

  def may_approve?(user)
    user == recipient
  end

  def may_view?(user)
    may_create?(user) or may_approve?(user)
  end

  def after_approval
    group.memberships.create :user => recipient, :group => group
  end

end

