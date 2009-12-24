@plain
Feature: Adding a location to a group
  In order to add a location to a group
  as an administrator of that group
  I add a country and state or city to the public profile

Background:
  Given a group: "rainbow" exist with name: "Rainbow"
  And a user: "blue" exists with display_name: "Blue"
  And geo data exists
  And that user is a member of that group
  And I am logged in as that user
  And I am on that group's landing page
  And I follow "Edit Settings"
  And I follow "Public Profile"

Scenario: Adding a country only
  Then I should see "Location"
  When I set the country "Netherlands"
  And I press "Save"
  Then I should see "Changes saved"
  And country Netherlands should be selected
