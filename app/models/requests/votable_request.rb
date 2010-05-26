# parent class for votable requests

class VotableRequest < Request
  named_scope :voting_completed, lambda {
    # use lamba here so that VOTE_DURATION.ago is evaluated freshly each time
    {:conditions => ["state = 'pending' AND created_at <= ?", self.vote_duration.ago]}
  }

#  named_scope :unvoted_by_user, lambda { |user|
#    {:include => :votes}
#  }

  def self.vote_duration
    1.month
  end

  def votable?
    true
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

  # will update state for the request
  def tally!
    group_members_count = group.users_allowed_to_vote_on_removing(user).length

    approve_votes_count = votes.approved.count
    reject_votes_count = votes.rejected.count


    if created_at > self.class.vote_duration.ago
      # max voting period has not passed
      # subclass defines these method
      tallied_state = instantly_tallied_state(group_members_count, approve_votes_count, reject_votes_count)
    else
      # max voting period has passed
      tallied_state = delayed_tallied_state(group_members_count, approve_votes_count, reject_votes_count)
    end


    set_state!(tallied_state, created_by) if tallied_state
  end

  protected

  # this should be called periodically (every hour is good)
  # it will see if the voting period is over and will count the votes
  # for all pending requests
  def self.tally_votes!
    tally_requests = self.voting_completed
    tally_requests.each do |request|
      request.tally!
    end
  end
end
