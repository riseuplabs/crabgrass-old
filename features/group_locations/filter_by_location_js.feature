@js @wip
Feature: Filter groups by location
  In order to see groups in a certain location
  as a user
  I go to groups directory and select location data

Background:
  Given a user: "blue" exists with display_name: "Blue"
  And geo data exists
  And I am logged in as that user
  And I am on the group directory page

Scenario: Check Country and State Dropdowns
  When I search by country "Netherlands"
  And I wait for the AJAX call to finish
  And I search by state "Utrecht"
  Then show me the div with id "state_dropdown"

#Scenario: Filter by country
#  Then show me the div with id "filter_by_location"
#  When I search by country "Netherlands" 
#  And I wait for the AJAX call to finish
#  And I press "filter by location"
#  Then I should see "rainbow"

### will need to create geo location for a group to check results
