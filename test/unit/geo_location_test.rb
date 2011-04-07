require File.dirname(__FILE__) + '/../test_helper'

class GeoLocationTest < ActiveSupport::TestCase
  fixtures :users, :geo_locations, :profiles

  def test_country_id_required
    geo_location = GeoLocation.new()
    assert !geo_location.save, "Saved GeoLocation without country id."
  end

  def test_with_visible_groups_with_unauth_user
    user = UnauthenticatedUser.new
    locations = GeoLocation.with_geo_place.with_visible_groups(user)
    assert_equal ['2','2'], locations.map(&:count)
  end

  def test_with_visible_groups_with_auth_user_with_access
    user = users(:blue)
    locations = GeoLocation.with_geo_place.with_visible_groups(user)
    assert_equal ['3','2'], locations.map(&:count)
  end

  def test_with_visible_groups_with_auth_user_without_access
    user = users(:red)
    locations = GeoLocation.with_geo_place.with_visible_groups(user)
    assert_equal ['2','2'], locations.map(&:count)
  end
end
