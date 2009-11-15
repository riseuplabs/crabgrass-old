Given /^I am not logged in$/ do
  Given "I am on the logout page"
end

Given /^I am logged in as #{capture_model}$/ do |user|
  user = model(user)

  visit path_to("the login page")
  fill_in "Login name", :with => user.login
  fill_in "Password", :with => user.login

  click_button "Log in"

  # this assert is more important than it looks. it makes sure that in selenium
  # mode webrat will wait for the redirect to the dashboard. this ensure that it will use response body to set the cookies
  assert_contain "Logout #{user.display_name}"
end
