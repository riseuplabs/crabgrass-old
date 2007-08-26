require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

  fixtures :users, :groups, :memberships

  def setup
    TzTime.zone = TimeZone["Pacific Time (US & Canada)"]
  end

  def test_memberships
    u = create_user
    g = Group.find 1
    oldcount = g.users.count
    u.groups << g
    assert oldcount < g.users.count, "group should have more users after add user"   
    assert_nothing_raised("group.users.find should return user") do
      g.users.find(u.id)
    end
    assert_nothing_raised("user.group.find should return group") do
      u.groups.find(g.id)
    end
    
  end

  ## ensure that a user and a group cannot have the same handle
  def test_namespace
    assert_no_difference User, :count do
      u = create_user(:login => 'groups')
      assert u.errors.on(:login)
    end
  
    g = Group.create :name => 'robot-overlord'
    assert_no_difference User, :count do
      u = create_user(:login => 'robot-overlord')
      assert u.errors.on(:login)
    end
  end
  
  def test_associations
    assert check_associations(User)
  end
  
  protected

  def create_user(options = {})
    User.create({ :login => 'mrtester', :email => 'mrtester@riseup.net', :password => 'test', :password_confirmation => 'test' }.merge(options))
  end
  
end
