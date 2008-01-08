require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < Test::Unit::TestCase

  fixtures :users, :groups

  def setup
    TzTime.zone = TimeZone["Pacific Time (US & Canada)"]
  end

  def test_adding_profile
    u = users(:blue)
    p = u.profiles.create :stranger => true, :first_name => 'Blue'

    assert p.valid?, 'profile should be created'
    assert_equal u.id, p.entity_id, 'profile should belong to blue'
    
    p.save_from_params(
      :last_name => 'McBlue',
      :phone_numbers => {
        1 => {:phone_number_type => 'Home', :phone_number => '(206) 555-1111'},
        2 => {:phone_number_type => 'Cell', :phone_number => '(206) 555-2222'}
      }
    )
    assert_equal '(206) 555-1111', p.phone_numbers.first.phone_number, 'save_from_params should update phone_numbers'

  end
  
  def test_permissions
    blue = users(:blue)
    red = users(:red)
    
    red.contacts << blue unless red.contacts.include?(blue)
    
    blue.profiles.create :friend => true, :organization => 'rainbows'
    blue.profiles.create :stranger => true, :organization => 'none'
        
    profile = blue.profiles.visible_by(red)
    assert profile, 'red should be able to view blue profile'
    assert_equal "rainbows", profile.organization, "should show organization 'rainbows' in profile"
    
    profile = blue.profiles.visible_by(nil)
    assert profile, 'there should be a public profile'
    assert_equal "none", profile.organization, "should show organization 'none' in profile"
  end

  def test_single_table_inheritance
    user = users(:kangaroo)
    p = user.profiles.create :stranger => true
    assert_equal 'User', p.entity_type, 'polymorphic association should work even with single table inheritance'
  end
    
  def test_wiki
    g = Group.create :name => 'trees'
    assert g.profiles.public, 'there should be a public profile'
    w = g.profiles.public.create_wiki
    assert_equal w.profile, g.profiles.public, 'wiki should have a profile'
  end
  
  def test_find_by_access
    g = Group.create :name => 'berries'
    p1 = g.profiles.create(
      :stranger => true, 
      :may_see => true, 
      :may_see_committees => false, 
      :may_see_members => false,
      :may_request_membership => true
    )
    p2 = g.profiles.find_by_access(:stranger)
    p3 = g.profiles.public
    
    assert_equal p1.id, p2.id, 'find_by_access should have returned the profile we just created'
    assert_equal p1.id, p3.id, 'profiles.public should return the profile we just created'
  end
  
  
  def test_associations
    assert check_associations(Profile::Profile)
  end
  
end

