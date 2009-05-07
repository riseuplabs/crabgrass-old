require File.dirname(__FILE__) + '/../test_helper'

class ActivityTest < ActiveSupport::TestCase
  fixtures :users, :groups, :activities, :memberships, :federatings, :sites

  def current_site
    Site.find_by_network_id(3002)  # we are using the second site with animals here.
  end

  def test_contact
    u1 = users(:kangaroo)
    u2 = users(:iguana)

    u1.add_contact!(u2)

    act = FriendActivity.for_dashboard(u1,current_site).find(:first)
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

    act = UserDestroyedActivity.for_dashboard(u1,current_site).find(:first)
    assert act, 'there should be a user destroyed activity created'
    assert_equal username, act.username
  end

  def test_group_destroyed
    user = users(:kangaroo)
    group = groups(:animals)

    assert user.member_of?(group)
    groupname = group.name
    group.destroy

    acts = Activity.for_dashboard(user,current_site).find(:all)
    act = acts.detect{|a|a.class == GroupDestroyedActivity}
    assert_equal groupname, act.groupname
    assert_in_description(act, group)
  end

  def test_group_created
    user = users(:green)
    notified_user = users(:kangaroo)
    group = Group.create!(:name => "plants",
                          :fullname =>"All the plants",
                          :summary =>"the plants can party tooo!" ) do |group|
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

  def test_membership
    group = groups(:animals)
    user = users(:green)
    notified_user = users(:kangaroo)

    group.add_user!(user)
    # user is not on current_site.
    assert_nil UserJoinedGroupActivity.for_dashboard(notified_user,current_site).find_by_subject_id(user.id)

    # this would be normally happen on login:
    current_site.network.add_user!(user)

    # this will be joining :animals because current_site.network is not on current_site.
    act = GroupGainedUserActivity.for_dashboard(notified_user,current_site).last

##
## DISABLED: i don't know what this is trying to do, and Site.default should never
## be used.
##
#    # animals are on current_site which is not the default one...
#    if Site.default.network.nil?
#      # green joined current_site.network after :animals
#      assert_not_equal act, GroupGainedUserActivity.for_dashboard(notified_user,Site.default).last
#      assert_equal act, GroupGainedUserActivity.for_dashboard(notified_user,Site.default).find(:last, :conditions => {:subject_id => group.id})
#    else
#      assert_nil GroupGainedUserActivity.for_dashboard(notified_user,Site.default).last
#    end
    assert_equal group.id, act.group.id

    act = GroupGainedUserActivity.for_group(group, notified_user).last
    assert_equal GroupGainedUserActivity, act.class
    assert_equal group.id, act.group.id

    # users own activity should always show up:
    act = UserJoinedGroupActivity.for_dashboard(user,current_site).last
    assert_equal group.id, act.group.id

    group.remove_user!(user)
  
    act = GroupLostUserActivity.for_dashboard(notified_user, current_site).last
    assert_activity_for_user_group(act, user, group)

    act = GroupLostUserActivity.for_group(group, notified_user).last
    assert_activity_for_user_group(act, user, group)

    act = UserLeftGroupActivity.for_dashboard(user, current_site).last
    assert_activity_for_user_group(act, user, group)

  end


  def test_deleted_subject
    u1 = users(:kangaroo)
    u2 = users(:iguana)

    u1.add_contact!(u2)
    act = FriendActivity.for_dashboard(u1,current_site).find(:first)
    u2.destroy

    assert act, 'there should be a friend activity created'
    assert_equal nil, act.other_user
    assert_equal 'iguana', act.other_user_name
    assert_equal '<span class="user">iguana</span>', act.user_span(:other_user)
  end

  def test_associations
    assert check_associations(Activity)
  end

  def test_message_page
    u1 = users(:kangaroo)
    u2 = users(:iguana)

    @page = Page.make :private_message, :to => [u2], :from => u1, :title => "testing message_page activity", :body => "test message body"

    act = MessagePageActivity.for_dashboard(u2,current_site).find(:first)
    assert_equal u2, act.user
    assert_equal u1, act.other_user
    assert_equal @page.id, act.message_id
  end

  def assert_activity_for_user_group(act, user, group)
    assert_equal group.id, act.group.id
    assert_equal user.id, act.user.id
    assert_in_description(act, group)
    assert_in_description(act, user)
    assert_not_nil act.icon
  end

  def assert_in_description(act, thing)
    name = thing.respond_to?("display_name") ?
      thing.display_name :
      thing.name
    assert_match name, act.description
  end

end

