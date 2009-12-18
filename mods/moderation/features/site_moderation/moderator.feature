Feature: Moderation for the whole sites content
  In order to moderate content of the whole site
  As a member of the site's moderation group
  I want to moderate the site's content and I want to not be able to modify content.

Background:
  Given I exist
  And a group: "moderators" exists
  And I am a member of that group
  And a site exists with name: "moderation", moderation_group: the group
  And We are on that site
  And I am logged in
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

Scenario: I should see moderated pages even if they are not for my group
  Given a page: "others-smell" exists with title: "Smelly Others", site: that site
  And a moderated_flag exists with flagged: that page
  And I am on the moderation panel
  Then I should see "Smelly Others"

Scenario: I should see moderated posts even to pages of other groups/users
  Given a page: "others" exists with title: "Others Content", site: that site
  And a post: "smelly" comments that page with body: "Others Smelly Post"
  And a moderated_flag exists with flagged: that post
  And I am on the moderation panel
  And I follow "Comment Moderation"
  Then I should see "Others Smelly Post"
