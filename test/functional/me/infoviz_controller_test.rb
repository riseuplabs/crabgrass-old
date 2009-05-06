require File.dirname(__FILE__) + '/../../test_helper'
require 'me/infoviz_controller'

# Re-raise errors caught by the controller.
class Me::InfovizController; def rescue_action(e) raise e end; end

class InfovizControllerTest < Test::Unit::TestCase
  fixtures :users, :user_participations, :groups, :group_participations, :pages

  def setup
    @controller = Me::InfovizController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_visualize
    if enabled?
      login_as :blue

      get :visualize, :format => 'png'
      assert_response :success

      get :visualize, :format => 'svg'
      assert_response :success
    end
  end

  def enabled?
   `which fdp`.any?
  end

end
