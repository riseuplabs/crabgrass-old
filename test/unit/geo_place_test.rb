require File.dirname(__FILE__) + '/../test_helper'

class GeoPlaceTest < ActiveSupport::TestCase
  fixtures :users, :geo_places, :profiles, :sites, :groups, :geo_countries, :geo_places, :geo_admin_codes
  
  def setup
    enable_site_testing
  end

  def teardown
    disable_site_testing
  end


  def test_finding_largest
    country = GeoCountry.make
    places = []
    (1..12).each do |i|
      GeoPlace.make :geo_country => country,
        :population => i*1000,
        :name => "place_#{i}"
    end
    result = country.geo_places.largest(10).all
    assert_equal 10, result.count
    assert_equal "place_12", result[0].name
    assert_equal 12000, result[0].population
    assert_equal "place_3", result[9].name
    assert_equal 3000, result[9].population
  end

  def test_find_by_name
    country = GeoCountry.make
    places = []
    %w(Berlin Bristol Bern Tokyo).each do |name|
      GeoPlace.make :geo_country => country,
        :population => rand(1000000),
        :name => name
    end
    result = country.geo_places.named_like("B")
    assert_equal 3, result.count
    result = country.geo_places.named_like("Be")
    assert_equal 2, result.count
    assert_equal %w(Berlin Bern), result.map(&:name).sort
  end

  def test_with_visible_groups_with_unauth_user
    user = UnauthenticatedUser.new
    places = GeoPlace.with_visible_groups(user, sites(:local))
    assert_equal ['2','2'], places.map(&:group_count)
  end

  def test_with_visible_groups_with_auth_user_with_access
    user = users(:blue)
    places = GeoPlace.with_visible_groups(user, sites(:local))
    assert_equal ['3','2'], places.map(&:group_count)
  end

  def test_with_visible_groups_with_auth_user_without_access
    user = users(:red)
    places = GeoPlace.with_visible_groups(user, sites(:local))
    assert_equal ['2','2'], places.map(&:group_count)
  end

  def test_place_with_multiple_groups_have_multiple_groups
    place = GeoPlace.find(1)
    assert place.profiles.count > 1, "place1 should have multiple groups" 
  end
end
