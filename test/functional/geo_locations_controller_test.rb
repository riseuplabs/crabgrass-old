require File.dirname(__FILE__) + '/../test_helper'

class GeoLocationsControllerTest < ActionController::TestCase
  fixtures :users, :groups, :memberships, :profiles, :federatings, :geo_countries, :geo_places, :geo_locations

  def setup
    enable_site_testing
  end

  def teardown
    disable_site_testing
  end

  def test_index_kml_with_login
    get :index, :format => 'kml'
    assert_response :success

    login_as :blue
    get :index, :format => 'kml'
    assert_response :success
    assert_equal 4, assigns['locations'].first.group_profiles(users(:blue)).count, "Four groups in the first location for blue."
    assert @response.body.index '<description>ajax:/geo_locations/show/1</description>'
  end

  def test_index_kml_without_login
    get :index, :format => 'kml'
    assert_response :success

    get :index, :format => 'kml'
    assert_response :success
    assert_equal 3, assigns['locations'].first.group_profiles(nil).count, "Three public groups in the first location."
    assert @response.body.index '<description>ajax:/geo_locations/show/1</description>'
  end

  def test_index_for_network_without_login
    get :index, :format => 'kml', :network_id => 'cnt'
    assert_response :success
    assert_equal 3, assigns['locations'].first.group_profiles(nil).count,
      "Three public groups in the first location is part of CNT network."
    assert @response.body.index '<description>ajax:/geo_locations/show/1</description>'
  end

  def test_show_without_network
    get :show, :id => 1
    assert_response :success
    assert_equal ['animals', 'rainbow','recent_group'], assigns['groups'].map(&:name).sort,
      "Rainbow and Recent Group should be listed as public groups in location 1"
  end

  def test_show_with_network_and_login
    login_as :blue
    get :show, :id => 1, :network_id => 'cnt'
    assert_response :success
    assert_equal ['private_group','rainbow'], assigns['groups'].map(&:name).sort,
      "Rainbow and Private Group should be visible to blue in location 1 as CNT members"
  end
end


