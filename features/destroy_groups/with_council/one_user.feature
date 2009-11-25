@js
Feature: Destroying groups that have a council
  In order to remove an inactive, a hijacked or an old group
  As a member of that group
  I want destroy that group immediately

Background:
  Given a group: "rainbow" exist with name: "Rainbow"
  And that group has a council
  And a user: "blue" exists with name: "Blue"
  And that user is a member of that group
  And I am logged in as that user
  And I am on the group's landing page

Scenario: I am not part of the council so I can't destroy the group
  Then I should not see a "Destroy Group"
  And I should not see "Propose to destroy this group"

Scenario: I am the only member of the council so I can destroy the group
  Given I am the only member of that group's council
  And a user: "red" is a member of that group
  When I follow "Destroy Group"
  And I press "Destroy"
  Then I should be on my dashboard page
  And I should see "Group Destroyed"
  And that group should not exists
  And I should receive an email with subject: "Group Rainbow has been deleted by Blue!"
  And I should receive an email body containing a destroyed groups directory link

