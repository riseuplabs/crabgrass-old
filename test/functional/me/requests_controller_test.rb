require File.dirname(__FILE__) + '/../../test_helper'
require 'me/requests_controller'

class Me::RequestsControllerTest < ActionController::TestCase
  fixtures :groups, :users, :memberships, :requests

  # TODO: Add fixtures for requests to make results in all of these categories

  def test_from_me
    login_as :blue
    get :index, :view => 'from_me'
    assert_response :success
  end

  def test_to_me
    login_as :blue
    get :index
    assert_response :success
  end

end
