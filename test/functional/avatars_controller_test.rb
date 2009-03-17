require File.dirname(__FILE__) + '/../test_helper'
require 'avatars_controller'

# Re-raise errors caught by the controller.
class AvatarsController; def rescue_action(e) raise e end; end

class AvatarsControllerTest < Test::Unit::TestCase
  fixtures :avatars
  
  def setup
    @controller = AvatarsController.new
    @request    = ActionController::TestRequest.new
    @request.host = Site.default.domain
    @response   = ActionController::TestResponse.new
  end

  def test_create
# TODO: write this test
#    post :create
  end

  def test_show
    get :show, :id => 0
    assert_response :success
    
    post :show, :id => 0, :size => 'large'
    assert_response :success
  end

  # TODO: it would be nice to have tests for an avatar other than the default...
end
