require File.dirname(__FILE__) + '/../test_helper'
#require 'admin/base_controller'

# Re-raise errors caught by the controller.
#class Admin::BaseController; def rescue_action(e) raise e end; end

class Admin::BaseControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships

  def setup
#    @controller = Admin::BaseController.new
#    @request    = ActionController::TestRequest.new
#    @response   = ActionController::TestResponse.new

    Conf.enable_site_testing
  end

  def test_user_authorization
    login_as :blue
    get :index
    assert @controller.current_user.superadmin?, 'user blue should be a superadmin'
  end

end

