require File.dirname(__FILE__) + '/../../test_helper'
#require 'admin/base_controller'

## Re-raise errors caught by the controller.
##class Admin::BaseController; def rescue_action(e) raise e end; end

class Admin::SitesControllerTest < ActionController::TestCase

  fixtures :users, :sites

  def setup
    enable_site_testing('unlimited')
  end

  def teardown
    disable_site_testing
  end

  def test_all_profiles_visible
    login_as :blue
    post :update, :site => {:all_profiles_visible => '1'} 
    assert_response :success
    site_model = assigns('current_site')
    assert site_model.all_profiles_visible
  end

  def test_no_admin
    login_as :red
    get :index
    assert_permission_denied "only site admins may access the actions."
  end

  def test_no_site
    disable_site_testing
    login_as :penguin
    get :index
    assert_permission_denied "none of the base actions should be enabled without sites."
  end

end
