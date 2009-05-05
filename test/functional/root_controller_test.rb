require File.dirname(__FILE__) + '/../test_helper'
require 'root_controller'
#showlog
# Re-raise errors caught by the controller.
class RootController; def rescue_action(e) raise e end; end

class RootControllerTest < Test::Unit::TestCase
  fixtures :groups, :users, :pages, :memberships,
            :user_participations, :page_terms, :sites

  include UrlHelper

  def setup
    @controller = RootController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Conf.enable_site_testing
  end

  def test_index_logged_in
    login_as :red

    get :index
    if assigns["current_site"].network
      assert_response :success
    else
      assert_response :redirect
    end
  end

  def test_index_not_logged_in
    get :index
    assert_response :success
  end

  def test_site_home
    login_as :red
    site_name="site2"
    @request.host = Site.find_by_name(site_name).domain
    get :index
    assert_response :success
    # just make sure the Site specific stuff worked...
    assert_equal assigns["current_site"].name, site_name, "Response did not come from the site we expected. Please check config/crabgrass.test.yml."
    assert_not_equal assigns["users"], [], "Expecting a list of most active users."
    assert_not_equal assigns["groups"], [], "Expecting a list of most recent groups."
  end

end
