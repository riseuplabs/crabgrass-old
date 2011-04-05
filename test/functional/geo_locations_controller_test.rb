require File.dirname(__FILE__) + '/../test_helper'

class GeoLocationsControllerTest < ActionController::TestCase
  fixtures :users, :groups, :memberships, :profiles, :geo_countries, :geo_places, :geo_locations

  def test_index_kml_by_location
    get :index, :format => 'kml'
    assert_response :success

    login_as :blue
    get :index, :format => 'kml'
    assert_response :success
    assert @response.body =~ /Zangakatun/
    assert @response.body =~ /rainbow/
    assert @response.body =~ /recent_group/
  end

end


