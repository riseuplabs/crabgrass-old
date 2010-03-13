require File.dirname(__FILE__) + '/../test_helper'

class ActivityTest < ActiveSupport::TestCase
  fixtures :users, :groups, :activities, :memberships, :federatings, :sites

  def test_contact
    u1 = users(:kangaroo)
    u2 = users(:iguana)

    u1.add_contact!(u2, :friend)

    act = FriendActivity.social_activities_for_groups_and_friends(u1).find(:first)
    assert act, 'there should be a friend activity created'
    assert_equal u1, act.user
    assert_equal u2, act.other_user
  end

  def test_user_destroyed
    u1 = users(:kangaroo)
    u2 = users(:iguana)

    assert u1.peer_of?(u2)
    username = u2.name
    u2.destroy

    act = UserDestroyedActivity.social_activities_for_groups_and_friends(u1).find(:first)
    assert act, 'there should be a user destroyed activity created'
    assert_equal username, act.username
  end

  def test_group_destroyed
    user = users(:kangaroo)
    group = groups(:animals)

    assert user.member_of?(group)
    groupname = group.name
    group.destroy_by(user)

    acts = Activity.social_activities_for_groups_and_friends(user).find(:all)
    act = acts.detect{|a|a.class == GroupDestroyedActivity}
    assert_equal groupname, act.groupname
    assert_in_description(act, group)
  end

  def test_group_created
    user = users(:green)
    notified_user = users(:kangaroo)
    group = Group.create!(:name => "plants",
                          :fullname =>"All the plants") do |group|
      group.avatar = Avatar.new
      group.created_by = user
    end
    act = GroupCreatedActivity.find(:last)
    assert_activity_for_user_group(act, user, group)

    act = UserCreatedGroupActivity.find(:last)
    assert_activity_for_user_group(act, user, group)
    assert_equal group.id, act.group.id
    assert_equal user.id, act.user.id
    assert_in_description(act, group)
    assert_in_description(act, user)
  end

  def test_sites
    group = groups(:animals)
    user = users(:green)
    notified_user = users(:kangaroo)

    enable_site_testing(:unlimited)
    group.add_user!(user)
    act = GroupGainedUserActivity.social_activities_for_groups_and_friends(notified_user).last
    assert_equal group.id, act.group.id, 'the notified user should get this activity'

    enable_site_testing(:limited)
    act = GroupGainedUserActivity.social_activities_for_groups_and_friends(notified_user).last
    assert_equal nil, act, 'not visible from another site'

    disable_site_testing
  end

  def test_membership
    group = groups(:animals)
    user = users(:green)
    notified_user = users(:kangaroo)

    ##
    ## Add the user
    ##

    group.add_user!(user)

    assert_nil UserJoinedGroupActivity.social_activities_for_groups_and_friends(notified_user).find_by_subject_id(user.id), 'the notified user does not get this kind of activity message'

    act = GroupGainedUserActivity.social_activities_for_groups_and_friends(notified_user).last
    assert_equal group.id, act.group.id, 'the notified user should get this activity'

    act = GroupGainedUserActivity.for_group(group, notified_user).last
    assert_equal GroupGainedUserActivity, act.class
    assert_equal group.id, act.group.id

    # users own activity should always show up:
    act = UserJoinedGroupActivity.social_activities_for_groups_and_friends(user).last
    assert_equal group.id, act.group.id

    ##
    ## Remove the user
    ##

    group.remove_user!(user)

    act = GroupLostUserActivity.social_activities_for_groups_and_friends(notified_user).last
    assert_activity_for_user_group(act, user, group)

    act = GroupLostUserActivity.for_group(group, notified_user).last
    assert_activity_for_user_group(act, user, group)

    act = UserLeftGroupActivity.social_activities_for_groups_and_friends(user).last
    assert_activity_for_user_group(act, user, group)
  end

  def test_deleted_subject
    u1 = users(:kangaroo)
    u2 = users(:iguana)

    u1.add_contact!(u2, :friend)
    act = FriendActivity.social_activities_for_groups_and_friends(u1).find(:first)
    u2.destroy

    assert act, 'there should be a friend activity created'
    assert_equal nil, act.other_user
    assert_equal 'iguana', act.other_user_name
    assert_equal '<span class="user">iguana</span>', act.user_span(:other_user)
  end

  def test_avatar
    group = groups(:rainbow)
    u1 = users(:kangaroo)
    u2 = users(:iguana)

    u1.add_contact!(u2, :friend)
    u1.send_message_to!(u2, "hi u2")
    group.add_user!(u1)

    friend_act = FriendActivity.find_by_subject_id(u1.id)
    user_joined_act = UserJoinedGroupActivity.find_by_subject_id(u1.id)
    group_gained_act = GroupGainedUserActivity.find_by_subject_id(group.id)
    post_act = PrivatePostActivity.find_by_subject_id(u2.id)
    # we do not create PrivatePostActivities anymore
    assert_nil post_act


    # the person doing the thing should be the avatar for it
    # disregarding whatever is the subject (in the gramatical/language sense) of the activity
    assert_equal u1, friend_act.avatar
    assert_equal u1, user_joined_act.avatar
    assert_equal u1, group_gained_act.avatar
    #assert_equal u1, post_act.avatar
  end

  def test_associations
    assert check_associations(Activity)
  end

  def assert_activity_for_user_group(act, user, group)
    assert_equal group.id, act.group.id
    assert_equal user.id, act.user.id
    assert_in_description(act, group)
    assert_in_description(act, user)
    assert_not_nil act.icon
  end

  def assert_in_description(act, thing)
    assert_match thing.name, act.description
  end

end

