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
    assert_equal user.featured_fields[:location].street, "test"

    fields = site.get_featured_fields_for_user(user)
    assert fields.keys.include?(:location)
    site2 = Site.last
    fields = site2.get_featured_fields_for_user(user)
    assert fields.empty?
  end
  
  
end
