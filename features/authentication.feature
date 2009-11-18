Feature: Manage authentications
  In order to know that my private information is private and public information is public
  As an any user
  I want to be able to login to my private account if I have the credentials and logout

Scenario: don't show user's dashboard without logging in
  Given I am not logged in
  When I go to my dashboard page
  Then I should be on the login page

Scenario: User logs in
  Given a user exists with login: "green", display_name: "Green"
  And I am not logged in
  When I go to the login page
  And I fill in "Login name" with "green"
  And I fill in "Password" with "green"
  And I press "Log in"
  Then I should see "Logout Green"
  And I should be on my dashboard page
