Feature: The "My Work" feed shows my work pages
  In order to keep an overview over my work
  As a logged in user
  I want to be able to see my contributions, my pages and pages I am watching
  And I want to not be able to see other peoples contributions to other pages

Background:
  Given I exist
  And I am logged in

Scenario: I can see Pages I own
  Given a page exists with owner: the user: "me", title: "Look at my own page!"
  When I am on my work page
  Then I should see "Look at my own page!"

Scenario: I can see Pages I watch
  Given a page exists with title: "Watch me now!"
  And I watch that page
  When I am on my work page
  Then I should see "Watch me now!"

Scenario: I can see my own contributions
  Given a page exists with title: "Waiting for Contributions"
  And I have view access to that page
  And a post comments that page with user: the user: "me", body: "Here's what I got to say..."
  When I am on my work page
  Then I should see "Waiting for Contributions"

Scenario: I cannot see others pages
  Given a page exists with title: "None of my business"
  And I have admin access to that page
  And a post comments that page with body: "Here's what they got to say..."
  When I am on my work page
  Then I should not see "None of my business"

Scenario: I cannot see pages even if someone notified me
  Given a page exists with title: "You can't pester me..."
  And I have admin access to that page
  And a user notified me about that page
  When I am on my work page
  Then I should not see "You can't pester me..."

Scenario: I can not see Pages I don't own anymore
  Given a page exists with owner: the user: "me", title: "They took it away from me!"
  And a user owns that page
  When I am on my work page
  Then I should not see "They took it away from me!"

Scenario: I can not see Pages my group owns
  Given a group exists
  And a page exists with owner: that group, title: "I don't care what these people say!"
  When I am on my work page
  Then I should not see "I don't care what these people say!"
