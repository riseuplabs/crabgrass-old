require File.dirname(__FILE__) + '/../../test_helper'
require 'me/requests_controller'

# Re-raise errors caught by the controller.
class Me::RequestsController; def rescue_action(e) raise e end; end

class RequestsControllerTest < Test::Unit::TestCase
  fixtures :groups, :pages, :users, :memberships
  
  def setup
    @controller = Me::RequestsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # TODO: Add fixtures for requests to make results in all of these categories

  def test_from_me
    login_as :blue
    get :from_me
    assert_response :success
  end
  
  def test_to_me
    login_as :blue
    get :to_me
    assert_response :success
  end
end
