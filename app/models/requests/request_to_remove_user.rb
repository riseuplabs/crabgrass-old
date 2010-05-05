#
# An a group member requests to delete their group. this creates a proposal that others vote on
#
# recipient: the group that has the user
# requestable: the user to be removed
# created_by: person in group who wants to remove other user

class RequestToRemoveUser < VotableRequest

  validates_format_of :recipient_type, :with => /Group/
  validates_format_of :requestable_type, :with => /User/

  named_scope :for_group, lambda { |group|
    { :conditions => {:recipient_id => group.id} }
  }

  named_scope :for_user, lambda { |group|
    { :conditions => {:requestable_id => group.id} }
  }

  alias_attr :group, :recipient
  alias_attr :user, :requestable

  def requestable_required?
    true
  end

  def self.vote_duration
    2.weeks
  end

  def validate_on_create
    if RequestToRemoveUser.for_group(group).for_user(user).created_by(created_by).find(:first)
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
    group.remove_user!(user)
  end

  def description
    I18n.t(:request_to_remove_coordinator_user_description,
              :group => group_span(group),
              :group_type => group.group_type.downcase,
              :user => user_span(created_by),
              :target_user => user_span(user))
  end


  protected

  def instantly_tallied_state(total_possible_votes, approve_votes, reject_votes)
    if Rational(approve_votes, total_possible_votes) >= Rational(2, 3)
      return 'approved'
    elsif Rational(reject_votes, total_possible_votes) > Rational(1, 3)
      # can never get enough approve votes to set approve state
      return 'rejected'
    end
  end

  def delayed_tallied_state(total_possible_votes, approve_votes, reject_votes)
    total_votes = approve_votes + reject_votes
    # 0 rejections are instant win (even with 0 total votes)
    # 2/3 majority from total voters is required to win otherwise
    if reject_votes == 0 or Rational(approve_votes, total_votes) >= Rational(2, 3)
      return 'approved'
    else
      return 'rejected'
    end
  end

end
