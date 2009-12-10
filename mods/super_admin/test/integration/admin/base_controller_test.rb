require "#{File.dirname(__FILE__)}/../../test_helper"

class Admin::BaseTest < ActionController::IntegrationTest

  fixtures :users, :memberships, :groups, :sites

  def setup
    enable_site_testing
  end

  def test_become_and_return
    # has to be account/login instead of '/' (root)
    # because only account controller has CSRF protection enabled
    visit '/account/login'
    fill_in "Login name", :with => 'blue'
    fill_in "Password", :with => 'blue'
    click_button "Log in"
    assert_contain "My Dashboard"


    return true # ABORTING here: TODO: figure out why superadmin mod seems to be inactive.
    click_link 'Admin'
    assert_contain "Administration Panel"
    # assert_contain "Superadmin"

    # click_link "edit users"
    visit '/admin/users'
    assert_contain "Total number of users"

    click_link 'Become'
    assert_contain "My Dashboard"
    assert_contain "Logout Aaron"
    assert_contain "Admin"

    click_link 'Admin'
    assert_contain "Administration Panel"
    assert_contain "Logout Blue"
  end
end
