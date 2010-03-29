@js
Feature: The "My Work" feed can be filtered into different views
  In order to keep an overview over my work
  As a logged in user
  I want to be able to chose a view on my work
  I want to see the watched, edited, owned and unread pages in seperate views

Background:
  Given I exist
  And a page exists with owner: the user: "me", title: "Look at my own page!"
  And a page exists with title: "Watch me now!"
  And I have view access to that page
  And I watch that page
  And a page exists with title: "Waiting for Contributions"
  And I have admin access to that page
  And a post comments that page with user: the user: "me", body: "Here's what I got to say..."
  And a page exists with owner: the user: "me", title: "Look at my unread page!"
  And I have not read that page
  And I am logged in

Scenario: Pages I Own
  When I am on my work page
  And I select "Pages I Own" from my_work View
  And I wait for the AJAX call to finish
  Then I should see "Look at my own page!"
  And I should not see "Watch me now!"
  And I should not see "Waiting for Contributions"
  And I should see "Look at my unread page!"

Scenario: My Watched Pages
  When I am on my work page
  And I select "My Watched Pages" from my_work View 
  And I wait for the AJAX call to finish
  Then I should not see "Look at my own page!"
  And I should see "Watch me now!"
  And I should not see "Waiting for Contributions"
  And I should not see "Look at my unread page!"

Scenario: My Page Edits
  When I am on my work page
  And I select "My Page Edits" from my_work View
  And I wait for the AJAX call to finish
  Then I should not see "Look at my own page!"
  And I should not see "Watch me now!"
  And I should see "Waiting for Contributions"
  And I should not see "Look at my unread page!"

Scenario: Unread Pages
  When I am on my work page
  And I select "Unread Pages" from my_work View
  And I wait for the AJAX call to finish
  Then I should not see "Look at my own page!"
  And I should not see "Watch me now!"
  And I should not see "Waiting for Contributions"
  And I should see "Look at my unread page!"
