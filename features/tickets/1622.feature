Feature: Show wiki page while another user is editing it

Background:
  Given 2 users exist
  And a wiki exist with body: "this here wiki"
  And a wiki page exists with data: that wiki
  And the 1st user has edit access to that wiki page
  And the 2nd user has edit access to that wiki page
  And I am logged in as the 1st user
  And I go to that wiki page's edit tab

Scenario: Opening a wiki edited by another use doesn't cause head trauma
  Given I am logged in as the 2nd user
  When I go to that wiki page's show tab
  Then I should see "this here wiki"




