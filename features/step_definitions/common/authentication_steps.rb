Given /^I am not logged in$/ do
  Given "I am on the logout page"
end

Given /^I am logged in as #{capture_model}$/ do |user|
  user = model(user)

  When "I go to the login page"
  When "I fill in \"Login name\" with \"#{user.login}\""
  When "I fill in \"Password\" with \"#{user.login}\""
  When "I press \"Log in\""

  # make sure we really logged in
  Then "I should see \"Logout #{user.display_name}\""
end


Given /^I am logged in$/ do
  Given "I am logged in as user: \"me\""
end
