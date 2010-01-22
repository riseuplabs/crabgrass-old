require File.dirname(__FILE__) + '/../test_helper'
require 'pages_controller'
require 'set'

# Re-raise errors caught by the controller.
class PagesController; def rescue_action(e) raise e end; end

class PagesControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = PagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def teardown
  end

  def test_new
    login_as :quentin
    get :new
    assert_response :success
  end


end
