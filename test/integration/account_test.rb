require "#{File.dirname(__FILE__)}/../test_helper"

class AccountTest < ActionController::IntegrationTest
  def test_login_as_user
    visit '/'
    fill_in "Login name", :with => 'blue'
    fill_in "Password", :with => 'blue'

    click_button "Log in"

    assert_contain "My Dashboard"
  end

  def atest_logout_and_login_as_different_user
    login "gerrard"

    visit '/'
    click_link "Logout Gerrard!"

    assert_contain "Goodbye"
    assert_contain "You have been logged out"

    # log in as different user
    fill_in "Login name", :with => 'blue'
    fill_in "Password", :with => 'blue'

    click_button "Log in"

    assert_contain "My Dashboard"
    assert_contain "Blue!"
  end
end
