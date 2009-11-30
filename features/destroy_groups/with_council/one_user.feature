@js
Feature: Destroying groups that have a council
  In order to remove an inactive, a hijacked or an old group
  As the only member of that group's council
  I want destroy that group immediately

Background:
  Given a group: "rainbow" exist with full_name: "Rainbow"
  And that group has 3 members
  And that group has a council
  And I exist with display_name: "Blue"
  And I am a member of that group
  And I am a member of that council
  And I am logged in
  And I am on the group's landing page

Scenario: I am the only member of the council so I can destroy the group
  When I follow "Destroy Group"
  And I press "Delete"
  Then I should be on my dashboard page
  And I should see "Group Destroyed"
  And that group should not exist
  And that council should not exist
  And I should receive an email with subject: "Group Rainbow has been deleted by Blue!"
  # And I should receive an email body containing a destroyed groups directory link

Scenario: Destroying the group destroys its committee
  Given that group has a committee with name: "comintern"
  And I am a member of that committee
  When I follow "Destroy Group"
  And I press "Delete"
  And that group should not exist
  And that council should not exist
  And that committee should not exist
  And I should receive an email with subject containing "comintern has been deleted by Blue!"

