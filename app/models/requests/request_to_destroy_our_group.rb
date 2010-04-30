#
# An a group member requests to delete their group. this creates a proposal that others vote on
#
# recipient: the group to be destroyed
# requestable: the same group
# created_by: person in group who want their group to be destroyed
#
class RequestToDestroyOurGroup < VotableRequest

  validates_format_of :recipient_type, :with => /Group/

  named_scope :for_group, lambda { |group|
    { :conditions => {:recipient_id => group.id} }
  }

  alias_attr :group, :recipient

  def requestable_required?
    false
  end

  def validate_on_create
    if RequestToDestroyOurGroup.for_group(group).created_by(created_by).find(:first)
      errors.add_to_base(I18n.t(:request_exists_error, :recipient => group.display_name))
    end
  end

  def may_create?(user)
    user.may?(:admin, group)
  end

  def may_approve?(user)
    # only the creator can approve
    # but everyone can vote
    # always call set_value(state, created_by)
    created_by == user
  end

  def may_destroy?(user)
    may_approve?(user)
  end

  def may_view?(user)
    may_create?(user) or may_approve?(user)
  end

  def may_vote?(user)
    user.may?(:admin, group) and votes.by_user(user).blank?
  end

  def after_approval
    group.destroy_by(created_by)
  end

  def description
    I18n.t(:request_to_destroy_our_group_description,
              :group => group_span(group),
              :group_type => group.group_type.downcase,
              :user => user_span(created_by))
  end


  protected

  def instantly_tallied_state(total_possible_votes, approve_votes, reject_votes)
    return 'approved' if approve_vote >= (total_possible_votes - 1)
    return 'rejected' if reject_votes >= (total_possible_votes - 1)
  end

  def delayed_tallied_state
    total_votes = approve_votes + reject_votes
    # 0 rejections are instant win
    # 2/3 majority from total voters is required to win otherwise
    if reject_votes == 0 or Rational(approve_votes, total_votes) >= Rational(2, 3)
      return 'approved'
    else
      return 'rejected'
    end
  end

end
