require File.dirname(__FILE__) + '/../test_helper'

class SocialUserTest < Test::Unit::TestCase

  fixtures :users, :groups, :memberships, :pages

  def setup
    TzTime.zone = TimeZone["Pacific Time (US & Canada)"]
  end

  def test_memberships
    u = create_user :login => 'membershiptester'
    g = Group.find 1
    oldcount = g.users.count

    g.memberships.create :user => u
    # u.memberships.create :group => g (another valid way to do the same thing)
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

  def test_caching_and_function_all_groups
    u = create_user :login => 'hermione'
    assert_equal 0, u.all_groups.length

    g = Group.create :name => 'hogwarts-academy'
    g.memberships.create :user => u

    assert_equal 1, u.groups.length, 'should be one group'
    assert_equal 1, u.group_ids.length, 'should be one group (id)'
    assert_equal 1, u.all_group_ids.length, 'should be one group (all id)'

    # u.all_groups is already cached, and must be manually refreshed
    u.all_groups.reload
    assert_equal 1, u.all_groups.length, 'should be one group (all)'

  end
  
  def test_caching_and_function_all_groups_with_a_committee
    u = create_user :login => 'ron'
    assert_equal 0, u.all_groups.length

    g = Group.create :name => 'hogwarts-academy'
    g.memberships.create :user => u

    assert_equal 1, u.all_group_ids.length, 'should be one group'

    c = Committee.create :name => 'dumbledores-army', :parent => g
    
    assert_equal 1, u.group_ids.length, 'should be one direct group'
    assert_equal 1, u.groups.length, 'should be one direct group'
   
    # for the indirect membership values to be correct,
    # we must clear the cache and reload the options.  
    u.clear_cache
    u.reload

    assert_equal 2, u.all_group_ids.length, 'should be two groups overall'
    assert_equal 2, u.all_groups.length, 'should be two groups overall'
  end

  protected
    def create_user(options = {})
      User.create({ :login => 'mrtester', :email => 'mrtester@riseup.net', :password => 'test', :password_confirmation => 'test' }.merge(options))
    end
end
