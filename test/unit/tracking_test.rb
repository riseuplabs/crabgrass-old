require File.dirname(__FILE__) + '/../test_helper'

class TrackingTest < Test::Unit::TestCase

  fixtures :users, :groups, :memberships, :pages

  def setup
  end

  def test_group_view_tracked
    user = users(:blue)
    group = groups(:rainbow)
    assert user.memberships.find_by_group_id(group.id)
    Tracking.insert_delayed(:user => user, :group => group)
    Tracking.update_trackings
    visits = user.memberships.find_by_group_id(group.id).total_visits
    Tracking.insert_delayed(:user => user.id, :group => group.id)
    Tracking.update_trackings
    assert_equal visits+1, user.memberships.find_by_group_id(group.id).total_visits, 'total_visits should increment'
  end
  
end
