@js
Feature: Destroying groups that don't have a council and have only one remaining member
  In order to remove an inactive, a hijacked or an old group
  As the only remaining member of that group
  I want to be able to destroy that group immediately

Background:
  Given a group: "rainbow" exist with name: "rainbow", full_name: "Rainbow"
  And I exist with display_name: "Blue"
  And I am a member of that group
  And I am logged in
  Given I am on that group's landing page

Scenario: Destroying a group requires confirmation
  When I follow "Destroy Group"
  Then I should see "Are you sure you want to delete this group?"

Scenario: I can destroy the group
  When I follow "Destroy Group"
  And I press "Delete"
  Then I should be on my dashboard page
  And I should see "Group Destroyed"
  And that group should not exist
  And I should receive an email with subject: "Group Rainbow has been deleted by Blue!"
  # And I should receive an email with body containing the destroyed groups directory url

