require File.dirname(__FILE__) + '/../test_helper'

class TrackingTest < Test::Unit::TestCase

  fixtures :users, :groups, :memberships, :pages

  def setup
  end

  def test_group_view_tracked
    user = users(:blue)
    group = groups(:rainbow)
    assert membership = user.memberships.find_by_group_id(group.id)
    Tracking.insert_delayed(:user => user, :group => group)
    Tracking.process
    visits = membership.reload.total_visits
    Tracking.insert_delayed(:user => user.id, :group => group.id)
    Tracking.process
    assert_equal visits+1, membership.reload.total_visits, 'total_visits should increment'
  end

  def test_page_view_tracked_fully
    user = users(:blue)
    page = pages(:wiki) #id = 210
    group = groups(:rainbow)
    action = :view
    # let's clean things up first so they do not get in the way...
    Tracking.process
    Daily.update
    Hourly.find(:all).each{|h| h.destroy}
    assert_difference 'Hourly.count' do
      # 1, "hourly should be created for the tracked view" do
      assert_tracking(user, group, page, action)
      Tracking.process
    end
    assert_difference 'Daily.count' do
    #, 1, "daily should be created from the existing hourlies" do
      Daily.update
    end
  end

  # Testing the user seen functionality. We are tracking users this way in order
  # to avoid the database access for every action.

  def test_seeing_users
    Tracking.saw_user(4)
    Tracking.update_last_seen_users
    assert_not_nil old_timestamp=User.find(4).last_seen_at, "blue should have last_seen updated."
    sleep(1)
    Tracking.saw_user(4)
    Tracking.update_last_seen_users
    assert ( old_timestamp<User.find(4).last_seen_at), "blue should have last_seen updated."
  end

  # This can theoretically fail because of te insert_delayed not having inserted
  # anything yet - how ever this would only happen if the database table was locked
  # at that very moment. This would be rare for the testing db. I haven't seen it
  # happening as of now.
  def assert_tracking(user, group, page, action)
    Tracking.insert_delayed(:user => user, :group => group, :page => page, :action => action)
    track=Tracking.last
    assert_equal track.user.login, user.login, "User not stored correctly in Tracking"
    assert_equal track.group.name, group.name, "Group not stored correctly in Tracking"
    assert_equal track.page.title, page.title, "Page not stored correctly in Tracking"
    if action != :unstar
      assert_equal "#{action.to_s}s", ["views", "edits", "stars"].find{|a| Tracking.last.send a},
        'Tracking did not count the right action.'
      assert_equal 1, ["views", "edits", "stars"].select{|a| Tracking.last.send a}.count,
        'There shall be exactly one action counted.'
    else
      # TODO: check this before ActiveRecord gets in the way.
      assert_equal 0, ["views", "edits", "stars"].select{|a| Tracking.last.send a}.count,
        'For :unstar all values should evaluate to false.'
    end
  end
end
