require File.dirname(__FILE__) + '/../../../../test/test_helper'

class RootControllerTest < ActionController::TestCase
  fixtures :groups, :users, :pages, :memberships,
            :user_participations, :page_terms, :sites

  include UrlHelper

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

    with_site :test do
      get :index
      assert_response :success
      assert_not_nil assigns["current_site"].id
    end

    get :index
    assert_response :success
  end

  def test_site_home
    with_site :test do
      get :index
      assert_response :success

      # just make sure the Site specific stuff worked...
      assert_not_nil assigns["current_site"].id,
        "Response did not come from the site we expected."
      current_site=assigns["current_site"]

      assert_not_equal @controller.send(:most_active_users), [],
        "Expecting a list of most active users."
      assert_nil @controller.send(:most_active_users).detect{|u| !u.site_ids.include?(current_site.id)},
        "All users should be on current_site."
      # testing for #1929
      assert_select "a[href='/people/directory/browse']", "View All"

      assert_not_equal @controller.send(:most_active_groups), [],
        "Expecting a list of most recent groups."
      assert_nil @controller.send(:most_active_groups).detect{|u| u.site_id != current_site.id},
        "All groups should be on current_site."
      # testing for #1929
      assert_select "a[href='/groups/directory/search']", "View All"

      # testing for #1927
      assert_no_select 'h3', "Wiki",
        "There should be no wiki caption on site home"

    end
  end

  def test_fetching_pages
    with_site :test do
      get :recent_pages
      assert_response :success
    end
  end

end

