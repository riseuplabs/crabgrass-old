@plain 
Feature: Filter groups by location
  In order to see groups in a certain location
  as a user
  I go to groups directory and select location data
  Then I should see groups in that location
  and the pagination links should work

Background:
  Given a user: "blue" exists with display_name: "Blue"
  And I am logged in as that user 
  And geo data exists
  And a network: "rainbow" exists with full_name: "rainbow network"
  And that network's country is "Netherlands"
  And I am on the network directory page

Scenario: Filter by country with pagination links
  When I search by country "Netherlands" 
  And I press "Go"
  Then I should see "rainbow network"
  When I follow "All"
  Then I should see "rainbow network"
  And country Netherlands should be selected in the search form
