require "#{File.dirname(__FILE__)}/../../test_helper"

class Admin::BaseTest < ActionController::IntegrationTest

  fixtures :users, :memberships, :groups, :sites

  def setup
    enable_site_testing
  end

  def test_become_and_return
    host! 'test.host'
    # has to be account/login instead of '/' (root)
    # because only account controller has CSRF protection enabled
    visit '/account/login'
    fill_in "Login name", :with => 'blue'
    fill_in "Password", :with => 'blue'
    click_button "Log in"
    assert_response :redirect
    follow_redirect!
    assert_contain "Logout"
    assert_select "a[href='/blue']", "Profile"


    click_link 'Admin'
    assert_contain "Super Admin Powers"

    # click_link "edit users"
    visit '/admin/users'
    assert_contain "Become"

    click_link 'D'
    click_link 'Become'
    follow_redirect!
    assert_contain "Logout"
    assert_select "a[href='/dolphin']", "Profile"
    assert_contain "Admin"

    click_link 'Admin'
    follow_redirect!
    assert_contain "Super Admin Powers"
    assert_select "a[href='/blue']", "Profile"
  end
end
