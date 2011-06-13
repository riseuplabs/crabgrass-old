@plain @wip 
Feature: Filter groups and networks by location
  In order to see groups in a certain location
  as a user
  I go to groups directory and select location data
  Then I should see groups in that location
  and the pagination links should work

Background:
  Given a user: "blue" exists with display_name: "Blue"
  And I am logged in as that user 
  And geo data exists
  And a network: "potogold" exists with full_name: "potogold network"
  And that network's country is geo_country: "NL"
  And a network: "prism" exists with full_name: "prism network"
  And a group: "rainbow" exists with full_name: "rainbow"
  And that group's country is geo_country: "NL"

Scenario: Filter groups by country with pagination links
  When I am on the group directory page
  And I search by country "Netherlands" 
  And I press "Go"
  Then I should see "rainbow" within ".group_entry"
  When I follow "All"
  Then I should see "rainbow" within ".group_entry"
  And country Netherlands should be selected in the search form

Scenario: Filter networks by country with pagination links
  When I am on the network directory page
  Then I should see "potogold network" within ".group_entry"
  When I search by country "Netherlands" 
  And I press "Go"
  Then I should see "potogold network" within ".group_entry"
  And I should not see "prism network" within ".group_entry"
  When I follow "All"
  Then I should see "potogold network" within ".group_entry"
  And I should not see "prism network" within ".group_entry"
  And country Netherlands should be selected in the search form
