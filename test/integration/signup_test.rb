require "#{File.dirname(__FILE__)}/../test_helper"

class SignupTest < ActionController::IntegrationTest

  def test_signup_a_new_user
    visit "/"
    click_link "new account"

    fill_in "Your login name", :with => "TheUser"
    fill_in "Your Password", :with => "passwD!2$"
    fill_in "Confirm Password", :with => "passwD!2$"

    check "I accept the terms of the usage agreement"
    click_button "Sign up"

    assert_contain "Registration successful"
    assert_contain "My Dashboard"
  end

  def test_signup_existing_name_doesnt_work
    visit "/account/signup"

    fill_in "Your login name", :with => "blue"
    fill_in "Your Password", :with => "passwD!2$"
    fill_in "Confirm Password", :with => "passwD!2$"

    check "I accept the terms of the usage agreement"
    click_button "Sign up"

    assert_contain "Login is already taken"
  end

  def test_password_confirmation_must_match
    visit "/account/signup"

    fill_in "Your login name", :with => "TheUser"
    fill_in "Your Password", :with => "passwD!2$XXX"
    fill_in "Confirm Password", :with => "passwD!2$"

    check "I accept the terms of the usage agreement"
    click_button "Sign up"

    assert_contain "Password doesn't match confirmation"
  end

  def test_password_cant_be_blank
    visit "/account/signup"

    fill_in "Your login name", :with => "TheUser"
    fill_in "Your Password", :with => ""
    fill_in "Confirm Password", :with => ""

    check "I accept the terms of the usage agreement"
    click_button "Sign up"

    assert_contain "Password confirmation can't be blank"
    assert_contain "Password can't be blank"
  end
end
