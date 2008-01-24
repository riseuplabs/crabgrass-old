require File.dirname(__FILE__) + '/../test_helper'

class PollTest < Test::Unit::TestCase
  fixtures :polls

  def test_find_possibles
    poll = Poll::Poll.create
    p1 = poll.possibles.create(:name => 'p1')
    p2 = poll.possibles.create(:name => 'robot_destroyer')
    possibles = poll.possibles.find(:all, :include => {:votes => :user})
    assert_equal 2, possibles.size, 'there should be two possibles'
  end
  
  def test_associations
    assert check_associations(Poll::Poll)
  end

end
