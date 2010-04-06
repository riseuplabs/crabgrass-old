@plain @navigation @wip 
Feature: Test navigation

Scenario: Walk navigation structure 
  Given Navigation exists 
  When I am navigating from the root of the menu structure
  Then show the current navigation submenu 
