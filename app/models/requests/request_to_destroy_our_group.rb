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
  validates_format_of :requestable_type, :with => /Group/

  has_many :votes, :as => :votable, :class_name => "RequestVote"

  named_scope :for_group, lambda { |group|
    { :conditions => {:recipient_id => group.id},
      :conditions => {:requestable_id => group.id}}
  }

  named_scope :voting_completed, :conditions => ["state = 'pending' AND created_at < ?", VOTE_DURATION.ago]

  def group() recipient end

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
    user.may?(:admin, group)
  end

  def may_destroy?(user)
    created_by == user
  end

  def may_view?(user)
    may_create?(user) or may_approve?(user)
  end

  def after_approval
    group.destroy
  end

  def description
    I18n.t(:request_to_destroy_our_group_description,  :group => group_span(group), :user => user_span(created_by))
  end

  protected

  attr_reader :winning_vote

  def add_vote!(response, user)
    response_map = {
      'reject' => 0,
      'approve' => 1
    }

    value = response_map[response]
    votes.by_user(user).destroy_all
    votes.create!(:value => value, :user => user)
  end

  # will update state for the request
  def tally!
    total_in_group = group.users.count
    total_votes = votes.count

    total_approved = votes.approved.count
    total_rejected = votes.rejected.count

    if total_approved >= (total_in_group - 1)
      # we're near unanimous to approve destroying this group
      set_state!('approved', created_by)
    elsif created_at < 1.month.ago
      state = has_winning_majority? ? 'approved' : 'rejected'
      set_state!(state, created_by)
    end
  end

  def has_winning_majority?(approve_votes, total_votes)
    # 2/3 majority from total voters is required to win
    Rational(approve_votes, total_votes) >= Rational(2, 3)
  end


  def self.tally_votes!
    tally_requests = RequestToDestroyOurGroup.voting_completed
    tally_requests.each do |request|
      request.tally!
    end
  end
end