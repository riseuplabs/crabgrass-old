require File.dirname(__FILE__) + '/../test_helper'
class FeaturedFieldsTest < Test::Unit::TestCase
  fixtures :sites, :users, :profiles
  
  def setup
    @site = Site.first
    @users = @site.users
    @user = @users.first

  end
  
  def test_featured_fields_setup
    site = @site

    user = @user
    user.profiles.public.locations.delete_all 
    
    assert site.set_featured_fields(:location => { :show => true}, :organization => { :show => true})  
    user.reload
    assert user.featured_fields.keys.include?(:location)
    assert_nil user.featured_fields[:location]
    assert location = user.profiles.public.locations.create(:street => "test")
    user.reload

    assert @site, 'site should exist'
    
    user = @user
    assert @user, 'user should exist'
    
    # we empty all featured fields
    
    user.profiles.public.locations.delete_all 
    
    user.featured_fields = nil
    user.save!
    user.reload
    
    assert !user.featured_fields.keys.include?(:location)
    
    # we define new featured fields
    
    assert site.set_featured_fields(:location => { :show => true}, :organization => { :show => true})  
    user.reload
    
    assert user.featured_fields.keys.include?(:location)
    
    # now the featured field location should be accessable, but be nil
    assert_nil user.featured_fields[:location]
    
    # we create a new location for the users public profile
    assert location = user.profiles.public.locations.create(:street => "test")
    user.reload
    

    assert_equal user.featured_fields[:location].street, "test"

    fields = site.get_featured_fields_for_user(user)
    assert fields.keys.include?(:location)
    site2 = Site.last
    fields = site2.get_featured_fields_for_user(user)
    assert fields.empty?
  end
  
  
end
