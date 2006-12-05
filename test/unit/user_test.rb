require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

  fixtures :users, :groups, :memberships

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

  def test_associations
    assert check_associations(User)
  end
  
#  def test_should_require_login
#    assert_no_difference User, :count do
#      u = create_user(:login => nil)
#      assert u.errors.on(:login)
#    end
#  end

  protected
    def create_user(options = {})
      User.create({ :login => 'mrtester', :email => 'mrtester@riseup.net', :password => 'test', :password_confirmation => 'test' }.merge(options))
    end
end
