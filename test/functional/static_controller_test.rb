require File.dirname(__FILE__) + '/../test_helper'
require 'static_controller'

# Re-raise errors caught by the controller.
class StaticController; def rescue_action(e) raise e end; end

class StaticControllerTest < Test::Unit::TestCase
  fixtures :avatars
  
  def setup
    @controller = StaticController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_avatar
    get :avatar, :id => 0
    assert_response :success
    
    post :avatar, :id => 0, :size => 'large'
    assert_response :success
  end

  # TODO: it would be nice to have tests for an avatar other than the default...
end
