Feature: Action bar navigation
  In order to navigate my stuff, I can use the action bar

Background:
  Given I exist
  And I am logged in
  And I have 30 pages

@js
Scenario: Pagination links work
  When I am on my work page
  And I check the checkbox with id "page_checkbox_1" 
  And I click on Read
  And I wait for the AJAX call to finish
  And I click on Next
  Then I should see "Page 30"
