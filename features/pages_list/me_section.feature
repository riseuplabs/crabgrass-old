Feature: Pages list appears correctly in me section
  In order to make sure the pages list is appearing correctly in the me section
  As a logged in user
  I want to see the correct owner details

Background:
  Given user: "blue" exists with display_name: "blue"
  And I am logged in as that user

Scenario: I can see the page details tooltip
  Given a page exists with owner: the user: "blue", title: "Look at my own page!"
  When I am on my work page
  Then I should see that page's owner details 
