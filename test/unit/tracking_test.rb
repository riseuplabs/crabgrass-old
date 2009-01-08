require File.dirname(__FILE__) + '/../test_helper'

class TrackingTest < Test::Unit::TestCase

  fixtures :users, :groups, :memberships, :pages

  def setup
    u = User.find(:first)
    g = u.groups.first
  end

  def test_group_view_tracked
    Tracking.insert_delayed(nil, u, g)
    visits = u.memberships.find_by_group_id(g.id).total_visits
    Tracking.update_trackings
    assert visits = u.memberships.find_by_group_id(g.id).total_visits + 1
  end
  
end
