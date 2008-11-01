require File.dirname(__FILE__) + '/../test_helper'

class ParticipationTest < Test::Unit::TestCase

  fixtures :groups, :users, :pages, :user_participations

  def setup
    Time.zone = TimeZone["Pacific Time (US & Canada)"]
  end

  def test_associations
    assert check_associations(UserParticipation)
  end

  def test_name_changed
    u = users(:orange)
    p = Page.create :title => 'hello', :user => u
    assert p.valid?, 'page should be valid'
    u.updated(p)
    p.save
    assert_equal 'orange', p.updated_by_login, 'cached updated_by_login should be "orange"'
    u.login = 'banana'
    u.save
    p.reload
    assert_equal 'banana', p.updated_by_login, 'cached updated_by_login should be "banana"'
  end
    
  def test_participations
    user = User.find 4
    group = Group.find 3
    
    page = Page.create :title => 'zebra'
        
    page.add(user, :star => true, :access => :admin)
    page.add(group, :access => :admin)
    page.save! # save required after .add()

    assert user.may?(:admin,page), 'user must be able to admin page'
    assert page.user_participations.find_by_user_id(user.id).star == true, 'user association attributes must be set'
    assert user.pages.include?(page), 'user must have an association with page'
    assert group.pages.include?(page), 'group must have an association with page'

    # page.users and page.groups are not updated until a reload 
    page.reload
    assert page.users.include?(user), 'page must have an association with user'
    assert page.groups.include?(group), 'page must have an association with group'
	
    page.remove(user)
    page.remove(group)
    page.save!
    assert !page.users.include?(user), 'page must NOT have an association with user'
    assert !page.groups.include?(group), 'page must NOT have an association with group'	
  end
  
  def test_user_destroyed
    user = users(:kangaroo)
    page = Page.create :title => 'boing'
    page.add(user)
    page.save!
    user.destroy
    assert !page.user_participations(true).any?
  end

  def test_ids_update
    user = users(:blue)
    page = Page.create! :title => 'robot tea party', :user => user
    assert_equal [user.id], page.user_ids
    page.remove(user)
    page.save!
    assert_equal [], page.user_ids
  end

end

