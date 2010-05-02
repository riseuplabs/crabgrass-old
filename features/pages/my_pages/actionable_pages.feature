Feature: The page feeds allow flagging the pages
  In order to keep an overview over my work
  As a logged in user
  I want to be able to mark my pages as (un)read and (un)watched

Background:
  Given I exist
  And I am logged in
  And a page exists with owner: the user: "me", title: "Look at my own page!"

Scenario: I can mark pages read
  When I am on my work page
  And I mark that page
  And I follow "Read"
  Then I should have read that page

Scenario: Multiple Selectors on My Pages
  When I am on my work page
  Then I should see "Select:"
  And I should see "All"
  And I should see "None"
  And I should see "Unread"

Scenario: Multiple Markers on My Pages
  When I am on my work page
  Then I should see "Mark as:"
  And I should see "Read"
  And I should see "Unread"
  And I should see "Unwatched"
