@js @wip
Feature: Destroying a request from me to another user from action bar works

Background:
  Given I exists with display_name: "Blue"
  And a user exists with display_name: "Stranger"
  And I am logged in
  And I request that user to be friends
  And I am on requests from me page

Scenario: I destroy a request
  When I check the checkbox for "Blue would like to be the friend of Stranger"
  And I follow "Destroy"
  Then I should not see "Blue would like to be the friend of Stranger"

