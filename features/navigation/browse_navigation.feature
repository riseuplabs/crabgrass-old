@plain @navigation @wip
Feature: Test navigation

Background: A Little bit of group setup
Given Navigation exists
And I exist
And a group exist with full_name: "The Animals"
And I am a member of that group

Scenario: Walk navigation structure 
When I am logged in
And I am navigating from the root of the menu structure
Then I should see the submenu links
And the submenu links should have the right path
And I should be able to click through all of the links

