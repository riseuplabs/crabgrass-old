@plain
Feature: Request to join a group
  In order to join a group which requires approval to join
  As a logged in user
  I click the link to join the group
  And I should see a request in my requests
  And a group administrator should see a request in their requests

Background:
  Given a group: "rainbow" exists with name: "Rainbow"
  And that group's join policy is by request
  And a user: "aubergine" exists with display_name: "Aubergine"
  And a user: "blue" exists with display_name: "Blue!"
  And the user: "blue" is a member of that group

Scenario: View My Request
  When I am logged in as user: "aubergine"
  And I am on group: "rainbow"'s landing page
  And I follow "Request to Join Group"
  And I press "Send Request"
  Then I should see "Request to join has been sent"
  When I view my requests
  Then I should see "Aubergine requests to join Rainbow"
  Then I log out

Scenario: View admin request
  When I am logged in as "blue"
  And I view my requests
  Then I should see "Aubergine requested to join Rainbow"
