require File.dirname(__FILE__) + '/../test_helper'

class SocialUserTest < Test::Unit::TestCase

  fixtures :users, :groups, :memberships, :pages

  def setup
    TzTime.zone = TimeZone["Pacific Time (US & Canada)"]
  end

  def test_memberships
    u = create_user
    g = Group.find 1
    oldcount = g.users.count

    g.memberships.create :user => u
    #u.memberships.create :group => g
    assert oldcount < g.users.count, "group should have more users after add user"   
    assert_nothing_raised("group.users.find should return user") do
      g.users.find(u.id)
    end
    assert_nothing_raised("user.group.find should return group") do
      u.groups.find(g.id)
    end
    assert u.member_of?(g), 'user must be a member_of? group'

    u.groups.delete g
    assert !u.member_of?(g), 'user must NOT be a member_of? group'
  end

  def test_contacts
    a = users(:red)
    b = users(:green)
    
    assert !a.contacts.include?(b), 'no contact yet'
    a.contacts << b
    assert a.contacts.include?(b), 'should be contact'
    a.reload
    assert a.friend_id_cache.include?(b.id), 'friend id cache should be updated'
    a.contacts.delete(b)
    assert !a.contacts.include?(b), 'no contact now'
  end

  def test_duplicate_contacts
    a = users(:red)
    b = users(:green)
    
    a.contacts << b
    assert_raises(AssociationError) do
      a.contacts << b
    end
    assert_equal 1, Contact.count(:conditions => ['user_id = ? and contact_id = ?', a.id, b.id]), 'should be only be one contact, but there are really two'
  end

  def test_duplicate_memberships
    u = create_user :login => 'harry-potter'
    g = Group.create :name => 'hogwarts-academy'
    
    u.memberships.create :group => g
    assert_raises(AssociationError) do
      u.memberships.create :group => g
    end
  end
  
  def test_associations
    assert check_associations(SocialUser)
    assert check_associations(Contact)
  end  

  protected
    def create_user(options = {})
      User.create({ :login => 'mrtester', :email => 'mrtester@riseup.net', :password => 'test', :password_confirmation => 'test' }.merge(options))
    end
end
