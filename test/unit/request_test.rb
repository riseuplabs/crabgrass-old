require File.dirname(__FILE__) + '/../test_helper'

class RequestTest < ActiveSupport::TestCase
  fixtures :users, :groups, :requests, :memberships

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

    assert_raises Exception, 'should only be able to redeem pending requests' do
      req = RequestToJoinUsViaEmail.redeem_code!(outsider, req.code, 'root@localhost')
    end

    assert outsider.member_of?(group), 'outsider should be added to group'
  end

  def test_associations
    assert check_associations(Request)
  end
  
end

