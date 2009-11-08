require File.dirname(__FILE__) + '/../test_helper'
require 'root_controller'
#showlog
# Re-raise errors caught by the controller.
class RootController; def rescue_action(e) raise e end; end

class RootControllerTest < ActionController::TestCase
  fixtures :groups, :users, :pages, :memberships,
            :user_participations, :page_terms, :sites

  include UrlHelper

  def teardown
  end

  def test_index_logged_in
    login_as :red

    with_site :test do
      get :index
      assert_response :success
    end

    get :index
    assert_response :redirect
  end

  def test_index_not_logged_in
    get :index
    assert_response :success
  end

  def test_site_home
    with_site :test do
      login_as :red
      get :index
      assert_response :success

      # just make sure the Site specific stuff worked...
      assert_not_nil assigns["current_site"].id, "Response did not come from the site we expected."
      current_site=assigns["current_site"]

      assert_not_equal @controller.send(:most_active_users), [], "Expecting a list of most active users."
      assert_nil @controller.send(:most_active_users).detect{|u| !u.site_ids.include?(current_site.id)},
        "All users should be on current_site."

      assert_not_equal @controller.send(:most_active_groups), [], "Expecting a list of most recent groups."
      assert_nil @controller.send(:most_active_groups).detect{|u| u.site_id != current_site.id},
        "All groups should be on current_site."
    end
  end

  # Examples for site testing:
  repeat_with_sites(:local => {:title => "Site One"}, :test => {:title => "Site Two"}) do
    # will generate two methods:
    # 1) test_title_with_site_local
    # 2) test_title_with_site_test
    def test_title
      get :index
      assert_select 'title', Site.current.title
    end
  end

  def test_local_title
    with_site :local do
      get :index
      assert_select 'title', "site1"
      assert_select 'title', Site.current.title
    end
  end
end

