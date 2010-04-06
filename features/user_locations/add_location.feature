@plain @wip
Feature: Adding a location to my public profile 
  In order to add a location to my public profile 
  as a logged in user
  I add a country and state or city to the public profile

Background:
  Given a user: "blue" exists with display_name: "Blue"
  And geo data exists
  And I am logged in as that user
  And I am on my dashboard page 
  And I follow "Account"
  And I follow "Public Profile"

Scenario: Adding a country only
  Then I should see "Location"
  When I set the country "Netherlands"
  And I press "Save"
  Then I should see "Changes saved"
  And country Netherlands should be selected
