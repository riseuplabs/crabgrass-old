@js
Feature: Expanding location fields in a form
  In order to set a country, state, and city
  I first choose a country and the state options are updated
  I can then choose a city and matching cities are returned

Background:
  Given a group: "rainbow" exist with name: "Rainbow"
  And a user: "blue" exists with display_name: "Blue"
  And geo data exists
  And that user is a member of that group
  And I am logged in as that user
  And I am on that group's landing page
  And I follow "Edit Settings"
  And I follow "Public Profile"

Scenario: Expanding the state/provinces list
  When I set the country "Netherlands"
  And I wait for the AJAX call to finish
  And I set the county "Utrecht"
  And I press "Save"
  Then I should see "Changes saved"
  And country Netherlands should be selected
