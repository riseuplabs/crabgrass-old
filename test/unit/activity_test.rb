require File.dirname(__FILE__) + '/../test_helper'

class ActivityTest < ActiveSupport::TestCase
  fixtures :users, :groups, :activities, :memberships, :federatings

  def test_contact
    u1 = users(:kangaroo)
    u2 = users(:iguana)

    u1.add_contact!(u2)

    act = Activity.for_dashboard(u1).find(:first)
    assert_equal ContactActivity, act.class
    assert_equal u1, act.user
    assert_equal u2, act.other_user
  end

  def test_user_destroyed
    u1 = users(:kangaroo)
    u2 = users(:iguana)

    assert u1.peer_of?(u2)
    username = u2.name
    u2.destroy

    acts = Activity.for_dashboard(u1).find(:all)
    act = acts.detect{|a|a.class == UserDestroyedActivity}
    assert_equal username, act.username
  end

  def test_group_destroyed
    user = users(:kangaroo)
    group = groups(:animals)

    assert user.member_of?(group)
    groupname = group.name
    group.destroy

    acts = Activity.for_dashboard(user).find(:all)
    act = acts.detect{|a|a.class == GroupDestroyedActivity}
    assert_equal groupname, act.groupname
  end

  def test_membership
    group = groups(:animals)
    user = users(:green)
    notified_user = users(:kangaroo)

    group.add_user!(user)

    act = Activity.for_dashboard(notified_user).find(:first)
    assert_equal GroupGainedUserActivity, act.class
    assert_equal group.id, act.group.id

    act = Activity.for_group(group, notified_user).find(:first)
    assert_equal GroupGainedUserActivity, act.class
    assert_equal group.id, act.group.id

    acts = Activity.for_dashboard(user).find(:all)
    act = acts.detect{|a|a.class == UserJoinedGroupActivity}
    assert_equal group.id, act.group.id
  end

  def test_deleted_subject
    u1 = users(:kangaroo)
    u2 = users(:iguana)

    u1.add_contact!(u2)
    act = Activity.for_dashboard(u1).find(:first)
    u2.destroy

    assert_equal nil, act.other_user
    assert_equal 'iguana', act.other_user_name
    assert_equal '<span class="user">iguana</span>', act.user_span(:other_user)
  end

  def test_associations
    assert check_associations(Activity)
  end
  
end

