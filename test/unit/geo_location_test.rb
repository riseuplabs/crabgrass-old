require File.dirname(__FILE__) + '/../test_helper'

class GeoLocationTest < ActiveSupport::TestCase
  fixtures :users, :geo_locations, :profiles, :sites, :groups, :geo_countries, :geo_places, :geo_admin_codes

  def setup
    enable_site_testing
  end

  def teardown
    disable_site_testing
  end

  def test_country_id_required
    geo_location = GeoLocation.new()
    assert !geo_location.save, "Saved GeoLocation without country id."
  end

  def test_with_visible_groups_with_unauth_user
    user = UnauthenticatedUser.new
    locations = GeoLocation.with_geo_place.with_visible_groups(user, sites(:local))
    assert_equal ['2','2'], locations.map(&:count)
  end

  def test_with_visible_groups_with_auth_user_with_access
    user = users(:blue)
    locations = GeoLocation.with_geo_place.with_visible_groups(user, sites(:local))
    assert_equal ['3','2'], locations.map(&:count)
  end

  def test_with_visible_groups_with_auth_user_without_access
    user = users(:red)
    locations = GeoLocation.with_geo_place.with_visible_groups(user, sites(:local))
    assert_equal ['2','2'], locations.map(&:count)
  end

  def test_location_with_multiple_groups_have_multiple_groups
    location = geo_locations(:location1)
    assert location.groups.count > 1, "location1 should have multiple groups" 
  end

end
