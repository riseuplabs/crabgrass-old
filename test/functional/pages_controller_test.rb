require File.dirname(__FILE__) + '/../test_helper'
require 'pages_controller'
require 'set'

class PagesControllerTest < ActionController::TestCase
  fixtures :users

  def test_new
    login_as :quentin
    get :new
    assert_response :success
  end

end
