@wip
Feature: Pages display with tags that link to the corresponding searches
  In order to navigate using tags
  As a user
  I want to see the tags assigned to a page on that page and be able to click through them
  And I want to find the tag on the search page showing up

Background:
  Given a user: "cook" exists with display_name: "The Page Cook"
  And a group: "cuisine" exists
  And a page exists with owner: that user, title: "Spaghetti"
  And a group_participation exists with group: that group, page: that page
  And I exist
  And I have view access to that page
  And a tag exists with name: "Tasty food!"
  And a tagging exists with tag: that tag, taggable: that page

Scenario: I can follow the tag to the users tag search
  When I am on the page of that page
  Then I should see "Tasty food!"

Scenario: Now we actually click ;)
  When I am on the page of that page
  And I follow "Tasty food!"
  Then I should see "The Page Cook"
  And I should see "Search"
  And I should see "Spaghetti"

Scenario: Coming from the group
  When I am on that group's landing page
  And I follow "Spaghetti"
  Then I should see "Spaghetti"
  And I should see "Tasty food!"
  When I follow "Tasty food!"
  Then I should see "Cuisine"
  And I should see "Spaghetti"
