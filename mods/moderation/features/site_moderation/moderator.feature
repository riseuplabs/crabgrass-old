Feature: Moderation for the whole sites content
  In order to moderate content of the whole site
  As a member of the site's moderation group
  I want to moderate the site's content and I want to not be able to modify content.

Background:
  Given a group: "moderators" exists
  Given a site exists with name: "moderation", moderation_group: the group
  And a user exists
  And that user is a member of that group
  And I am logged in as that user on that site
  And I am on my dashboard page

Scenario: I am part of the moderation group so i can see the moderation tab
  Then I should see "Moderation"

Scenario: I can go to the moderation tab
  When I follow "Moderation"
  Then I should see "Moderation"
  And I should see "Page Moderation"
  And I should see "Flagged Pages"

Scenario: I can see all pages
  When I follow "Moderation"
  And I follow "See All Pages"
  Then I should see "There are no pages for this view"

