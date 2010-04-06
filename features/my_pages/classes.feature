Feature: The "My Pages" feeds show pages with appropriate classes
  In order to keep an overview over my pages
  As a logged in user
  I want to be able to see my pages with the right classes assigned

Background:
  Given I exist

Scenario: I can see Pages I did not read as unread
  Given a page exists with title: "Read me now!"
  And I have view access to that page
  And I watch that page
  And I am logged in
  And I have not read that page
  When I am on my work page
  Then I should see "Read me now!" within ".unread" 

Scenario: I can see Pages I read as read
  Given a page exists with title: "Read me already!"
  And I have view access to that page
  And I watch that page
  And I am logged in
  And I have read that page
  When I am on my work page
  Then I should see "Read me already!"
  And I should not see "Read me already!" within ".unread"
