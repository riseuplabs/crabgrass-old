require File.dirname(__FILE__) + '/../../test_helper'
require 'me/dashboard_controller'

# Re-raise errors caught by the controller.
class Me::DashboardController; def rescue_action(e) raise e end; end

class DashboardControllerTest < Test::Unit::TestCase
  fixtures :users, :user_participations, :groups, :group_participations, :pages, :sites, :activities

  def setup
    @controller = Me::DashboardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_dashboard
    login_as :quentin
    get :index
    assert_response :success
#    assert_template 'index'
  end

  def test_activities
    login_as :blue
    get :index
    assert_response :success
  end
end
