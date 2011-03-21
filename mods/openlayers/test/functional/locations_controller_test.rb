require File.dirname(__FILE__) + '/../test_helper'

class LocationsControllerTest < ActionController::TestCase
  fixtures :groups, :profiles, :geo_locations, :geo_countries, :geo_places

  def test_index
    get :index
    assert_response :success
  end

end
