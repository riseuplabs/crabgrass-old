@js
Feature: Setting group location 
  In order to set a location
  as an administrator of a group
  I choose a country and optionally choose a state and city
  and I see the changes saved.

Background:
  Given a group: "rainbow" exist with name: "Rainbow"
  And a user: "blue" exists with display_name: "Blue"
  And geo data exists
  And that user is a member of that group
  And I am logged in as that user
  And I am on that group's landing page
  And I follow "Edit Settings"
  And I follow "Public Profile"

Scenario: Setting country and county
  When I set the country "Netherlands"
  And I wait for the AJAX call to finish
  And I set the state "Utrecht"
  And I press "Save"
  Then I should see "Changes saved"
  And state Utrecht in country Netherlands should be selected
