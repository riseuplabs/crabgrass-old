#
# An a group member requests to delete their group. this creates a proposal that others vote on
#
# recipient: the group to be destroyed
# requestable: the same group
# created_by: person in group who want their group to be destroyed
#
class RequestToDestroyOurGroup < Request
  VOTE_DURATION = 1.month

  validates_format_of :recipient_type, :with => /Group/

  named_scope :for_group, lambda { |group|
    { :conditions => {:recipient_id => group.id} }
  }

  named_scope :voting_completed, lambda {
    # use lamba here so that VOTE_DURATION.ago is evaluated freshly each time
    {:conditions => ["state = 'pending' AND created_at <= ?", VOTE_DURATION.ago]}
  }

  named_scope :unvoted_by_user, lambda { |user|
    {:include => :votes}
  }

  alias_attr :group, :recipient

  def requestable_required?
    false
  end

  def votable?
    true
  end

  def validate_on_create
    if RequestToDestroyOurGroup.for_group(group).created_by(created_by).find(:first)
      errors.add_to_base(I18n.t(:request_exists_error, :recipient => group.display_name))
    end
  end

  def approve_by!(user)
    add_vote!('approve', user)
    tally!
  end

  def reject_by!(user)
    add_vote!('reject', user)
    tally!
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


  def self.value_for_state(state)
    state_map = {
      'rejected' => 0,
      'approved' => 1
    }

    state_map[state]
  end

  # will update state for the request
  def tally!
    group_members_count = group.users.count

    approve_votes_count = votes.approved.count
    reject_votes_count = votes.rejected.count

    if approve_votes_count >= (group_members_count - 1)
      # we're near unanimous to approve destroying this group
      set_state!('approved', created_by)
    elsif reject_votes_count >= (group_members_count - 1)
      # we're near unanimous to reject destroying this group
      set_state!('rejected', created_by)
    elsif created_at < VOTE_DURATION.ago
      # one months has passes, neither reject or approve is unanimous
      # count the votes
      state = has_winning_majority?(approve_votes_count, reject_votes_count) ? 'approved' : 'rejected'
      set_state!(state, created_by)
    end
  end

  protected

  attr_reader :winning_vote

  def add_vote!(response, user)
    response_map = {
      'reject' => 0,
      'approve' => 1
    }

    value = response_map[response]
    votes.by_user(user).delete_all
    votes.create!(:value => value, :user => user)
  end

  def has_winning_majority?(approve_votes, reject_votes)
    # 0 rejections are instant win
    return true if reject_votes == 0

    # 2/3 majority from total voters is required to win otherwise
    total_votes = approve_votes + reject_votes
    Rational(approve_votes, total_votes) >= Rational(2, 3)
  end

  # this should be called periodically (every hour is good)
  # it will see if the voting period is over and will count the votes
  # for all pending requests
  def self.tally_votes!
    tally_requests = RequestToDestroyOurGroup.voting_completed
    tally_requests.each do |request|
      request.tally!
    end
  end
end