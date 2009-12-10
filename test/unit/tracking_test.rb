require File.dirname(__FILE__) + '/../test_helper'

class TrackingTest < Test::Unit::TestCase

  fixtures :users, :groups, :memberships, :relationships, :pages

  def setup
  end

  def test_group_view_tracked
    user = users(:blue)
    group = groups(:rainbow)
    assert membership = user.memberships.find_by_group_id(group.id)
    assert_difference('Membership.find(%d).total_visits'%membership.id) do
      Tracking.insert_delayed(:current_user => user, :group => group)
      Tracking.process
    end
    assert_difference('Membership.find(%d).total_visits'%membership.id) do
      Tracking.insert_delayed(:current_user => user.id, :group => group.id)
      Tracking.process
    end
  end

  def test_user_visit_tracked
    current_user = users(:blue)
    user = users(:orange)

    assert_difference 'Tracking.count', 3 do
      3.times { Tracking.insert_delayed(:current_user => current_user, :user => user) }
    end
    assert_difference 'Tracking.count', -3 do
      Tracking.process
    end
    assert_equal 3, current_user.relationships.with(user).total_visits
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
    assert_no_difference 'Daily.count' do
      # daily should not be created for the new hourlies
      # we only create them with one day delay to avoid double counting.
      assert_difference 'Hourly.count' do
        # 1, "hourly should be created for the tracked view" do
        assert_tracking(user, group, page, action)
        Tracking.process
        Daily.update
      end
    end
    assert_difference 'Daily.count' do
      # we create trackings for the day before yesterday here
      # - so they should be counted.
      assert_no_difference 'Hourly.count' do
        # Hourly should be created for the tracked view
        # but then removed after being processed for daily.
        assert_tracking(user, group, page, action, Time.now - 2.days)
        Tracking.process
        Daily.update
      end
    end
  end

  def test_most_active_groups
    user = users(:blue)
    group1 = groups(:rainbow)
    group2 = groups(:animals)
    group3 = groups(:true_levellers)
    3.times { Tracking.insert_delayed(:current_user => user, :group => group1) }
    2.times { Tracking.insert_delayed(:current_user => user, :group => group2) }
    1.times { Tracking.insert_delayed(:current_user => user, :group => group3) }
    Tracking.process
    assert_equal [group1, group2, group3], user.primary_groups.most_active[0..2]
  end

  private

  # Insert delayed is not delaysed for testing so this should not cause problems.
  def assert_tracking(user, group, page, action, time=nil)
    Tracking.insert_delayed(:current_user => user, :group => group, :page => page, :action => action, :time => time)
    track=Tracking.last
    assert_equal track.current_user_id, user.id, "User not stored correctly in Tracking"
    assert_equal track.group_id, group.id, "Group not stored correctly in Tracking"
    assert_equal track.page_id, page.id, "Page not stored correctly in Tracking"
    if action != :unstar
      assert_equal "#{action.to_s}s", ["views", "edits", "stars"].find{|a| Tracking.last.send a},
        'Tracking did not count the right action.'
      assert_equal 1, ["views", "edits", "stars"].select{|a| Tracking.last.send a}.size,
        'There shall be exactly one action counted.'
    else
      # TODO: check this before ActiveRecord gets in the way.
      assert_equal 0, ["views", "edits", "stars"].select{|a| Tracking.last.send a}.size,
        'For :unstar all values should evaluate to false.'
    end
  end

end
