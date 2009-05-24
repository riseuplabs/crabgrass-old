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
    enable_site_testing :test do
      login_as :red
      get :index
      assert_response :success
      # just make sure the Site specific stuff worked...
      assert_not_nil assigns["current_site"].id, "Response did not come from the site we expected."
      current_site=assigns["current_site"]
      assert_not_equal assigns["users"], [], "Expecting a list of most active users."
      assert_nil assigns["users"].detect{|u| !u.site_ids.include?(current_site.id)}, 
        "All users should be on current_site."
      assert_not_equal assigns["groups"], [], "Expecting a list of most recent groups."
      assert_nil assigns["groups"].detect{|u|u.site_id != current_site.id}, 
        "All groups should be on current_site."
    end
  end

end
