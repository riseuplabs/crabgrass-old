require File.dirname(__FILE__) + '/../test_helper'

class PollTest < ActiveSupport::TestCase
  fixtures :polls, :users

  def test_find_possibles
    poll = Poll.create
    p1 = poll.possibles.create(:name => 'p1')
    p2 = poll.possibles.create(:name => 'robot_destroyer')
    possibles = poll.possibles.find(:all, :include => {:votes => :user})
    assert_equal 2, possibles.size, 'there should be two possibles'
  end

  def test_vote_destroyed_on_user_destruction
    dolphin = users(:dolphin)
    poll = RatingPoll.create
    p1 = poll.possibles.create(:name => 'smashed')
    v1 = poll.votes.create :user => dolphin,
      :possible => p1,
      :value => 2
    dolphin.destroy
    assert_equal 0, p1.votes.count
  end

  # we might have old votes around where the users do not exist anymore but
  # the votes have not been destroyed properly. These should not count.
  def test_vote_without_user_not_counted
    poll = RankingPoll.create
    p1 = poll.possibles.create(:name => 'smashed')
    v1 = poll.votes.create :user_id => 100,
      :possible => p1,
      :value => 0
    assert poll.tally.empty?, 'no top votes should be present'
  end

  def test_associations
    assert check_associations(Poll)
  end

end
