require File.dirname(__FILE__) + '/../test_helper'

class LocationsControllerTest < ActionController::TestCase
  fixtures :geo_locations, :geo_places, :geo_admin_codes, :geo_countries, :profiles, :groups, :users

  def test_index_kml
    get :index, :format => :kml
    assert_response :success
    puts @response.body
  end

  def test_only_groups
    user = users(:user_with_location)
    get :index, :format => :kml
    puts @response.body   
  end

end
