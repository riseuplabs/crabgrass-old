@js
Feature: Action bar navigation
  In order to navigate my stuff, I can use the action bar

Background:
  Given I exist
  And I am logged in
  And I have 30 pages

Scenario: Pagination links work
  When I am on my work page
  Then I should see "Page 18"
  And I check the checkbox with id "page_checkbox_18" 
  And I follow "Read"
  And I wait for the AJAX call to finish
  And I follow "Next"
  Then I should see "Page 1"
