@plain @navigation
Feature: Test navigation

Background: A Little bit of group setup
Given I exist
And a navigation exist
And a group exist with full_name: "The Animals", name: "animals"
And I am a member of that group

Scenario: Walk navigation structure
When I am logged in
And I am navigating from the root of that navigation
Then show the menu structure of that navigation
And I should be able to click through that navigation
