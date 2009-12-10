require File.dirname(__FILE__) + '/../test_helper'

class RequestTest < ActiveSupport::TestCase
  fixtures :users, :groups, :requests, :memberships, :federatings

  def test_request_to_friend
    u1 = users(:kangaroo)
    u2 = users(:iguana)

    assert !u1.friend_of?(u2)
    assert !u2.friend_of?(u1)

    req = RequestToFriend.create!(:created_by => u1, :recipient => u2)

    assert_raises ActiveRecord::RecordInvalid, "can't be duplicates" do
      RequestToFriend.create!(:created_by => u1, :recipient => u2)
    end

    assert_raises PermissionDenied do
      req.approve_by!(u1)
    end
    req.approve_by!(u2)
    assert_equal 'approved', req.state
    assert u1.friend_of?(u2), 'users should be friends'
    assert u2.friend_of?(u1), 'users should be friends'

    req.destroy
    assert_raises ActiveRecord::RecordInvalid, "contact already exists" do
      RequestToFriend.create!(:created_by => u1, :recipient => u2)
    end
  end

  def test_request_to_join_us
    insider  = users(:dolphin)
    outsider = users(:gerrard)
    group    = groups(:animals)

    assert insider.member_of?(group)
    assert !outsider.member_of?(group)
    assert !insider.peer_of?(outsider)
    assert !outsider.peer_of?(insider)

    req = RequestToJoinUs.create(
      :created_by => insider, :recipient => outsider, :requestable => group)
    assert req.valid?, 'request should be valid'

    assert_raises ActiveRecord::RecordInvalid, "can't be duplicates" do
      RequestToJoinUs.create!(
        :created_by => insider, :recipient => outsider, :requestable => group)
    end

    assert_equal req, Request.to_user(outsider).having_state('pending').find(:last)
    assert_equal req, Request.created_by(insider).having_state('pending').find(:last)
    assert_equal req, Request.from_group(group).having_state('pending').find(:last)

    assert_raises PermissionDenied do
      req.approve_by!(insider)
    end

    assert_nothing_raised do
      req.approve_by!(outsider)
    end

    assert outsider.member_of?(group), 'outsider should be added to group'

    insider.reload; outsider.reload
    assert insider.peer_of?(outsider)
    assert outsider.peer_of?(insider)

    req.destroy
    assert_raises ActiveRecord::RecordInvalid, "membership already exists" do
      RequestToJoinUs.create!(
        :created_by => insider, :recipient => outsider, :requestable => group)
    end
  end

  def test_bad_request_to_join
    insider  = users(:dolphin)
    outsider = users(:gerrard)
    group    = groups(:animals)

    req = RequestToJoinUs.create(
      :created_by => outsider, :recipient => insider, :requestable => group)
    assert !req.valid?, 'request should be invalid'
  end

  def test_request_to_join_you
    insider  = users(:dolphin)
    outsider = users(:gerrard)
    group    = groups(:animals)
    assert !outsider.member_of?(group)

    req = RequestToJoinYou.create(
      :created_by => outsider, :recipient => insider, :requestable => group)
    assert !req.valid?, 'request should be invalid: a user recipient should not be allowed'

    req = RequestToJoinYou.create(
      :created_by => outsider, :recipient => group)
    assert req.valid?, 'request should be valid: %s' % req.errors.full_messages.to_s

    assert_raises ActiveRecord::RecordInvalid, "can't be duplicates" do
      RequestToJoinYou.create!(:created_by => outsider, :recipient => group)
    end

    assert_equal req, Request.to_user(insider).having_state('pending').find(:first, :conditions => {:created_by_id => outsider})

    assert_raises PermissionDenied do
      req.approve_by!(outsider)
    end

    assert_nothing_raised do
      req.approve_by!(insider)
    end

    assert outsider.member_of?(group), 'outsider should be added to group'

    req.destroy
    assert_raises ActiveRecord::RecordInvalid, "membership already exists" do
      RequestToJoinYou.create!(:created_by => outsider, :recipient => group)
    end
  end

  def test_request_to_join_us_via_email
    insider  = users(:dolphin)
    outsider = users(:gerrard)
    group    = groups(:animals)

    req = RequestToJoinUsViaEmail.create(
      :created_by => insider, :email => 'root@localhost', :requestable => group)

    assert req.valid?, 'request should be valid: %s' % req.errors.full_messages.to_s
    assert req.code.length >= 6

    assert_nothing_raised do
      req = RequestToJoinUsViaEmail.redeem_code!(outsider, req.code, 'root@localhost')
    end

    assert_nothing_raised do
      req.approve_by!(outsider)
    end

    assert_raises ErrorMessage, 'should only be able to redeem pending requests' do
      req = RequestToJoinUsViaEmail.redeem_code!(outsider, req.code, 'root@localhost')
    end

    assert outsider.member_of?(group), 'outsider should be added to group'
  end

  def test_request_to_join_your_network
    user = users(:blue)
    network = groups(:fau)

    assert network.groups.include?(groups(:animals))
    assert_raises ActiveRecord::RecordInvalid, 'duplicate membership not allowed' do
      RequestToJoinYourNetwork.create!(:created_by => user, :recipient => network, :requestable => groups(:animals))
    end

    assert !network.groups.include?(groups(:rainbow))
    assert_raises ActiveRecord::RecordInvalid, 'kangaroo not part of rainbow not allowed' do
      RequestToJoinYourNetwork.create!(:created_by => users(:kangaroo), :recipient => network, :requestable => groups(:rainbow))
    end

    req = nil
    assert_nothing_raised do
      req = RequestToJoinYourNetwork.create!(:created_by => user, :recipient => network, :requestable => groups(:rainbow))
    end

    assert users(:gerrard).may?(:admin,network)
    assert_nothing_raised do
      req.approve_by!(users(:gerrard))
    end

    assert network.groups(true).include?(groups(:rainbow))
  end

  def test_request_to_join_our_network
    insider = users(:gerrard)
    group = groups(:rainbow)
    user  = users(:red)
    network = groups(:fau)

    assert network.groups.include?(groups(:animals))
    assert_raises ActiveRecord::RecordInvalid, 'duplicate membership not allowed' do
      RequestToJoinOurNetwork.create!(:created_by => users(:kangaroo), :recipient => groups(:animals), :requestable => network)
    end

    assert !network.groups.include?(group)
    assert_raises ActiveRecord::RecordInvalid, 'red not part of network' do
      RequestToJoinOurNetwork.create!(:created_by => user, :recipient => group, :requestable => network)
    end

    req = nil
    assert_nothing_raised do
      req = RequestToJoinOurNetwork.create!(:created_by => insider, :recipient => group, :requestable => network)
    end

    assert user.may?(:admin,group)
    assert_nothing_raised do
      req.approve_by!(user)
    end

    assert network.groups(true).include?(group)
  end

  def test_destroy_recipient
    u1 = users(:kangaroo)
    u2 = users(:iguana)

    req = RequestToFriend.create!(:created_by => u1, :recipient => u2)
    u1.destroy
    assert_raises ActiveRecord::RecordNotFound, 'request should have been destroyed' do
      Request.find(req.id)
    end

    insider  = users(:dolphin)
    outsider = users(:gerrard)
    group    = groups(:animals)

    req = RequestToJoinUs.create(
      :created_by => insider, :recipient => outsider, :requestable => group)

    group.destroy_by(insider)
    assert_raises ActiveRecord::RecordNotFound, 'request should have been destroyed' do
      Request.find(req.id)
    end
  end

  def test_associations
    assert check_associations(Request)
  end

end

