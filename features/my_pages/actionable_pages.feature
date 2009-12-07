Feature: The page feeds allow flagging the pages
  In order to keep an overview over my work
  As a logged in user
  I want to be able to mark my pages as (un)read and (un)watched

Background:
  Given I exist
  And I am logged in
  And a page exists title: "Look at my own page!"

Scenario: I can mark pages read
  When I am on my work page
  And I check the box for that page
  And I press "Read"
  Then I should have read that page
