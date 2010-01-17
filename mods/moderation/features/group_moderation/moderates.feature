Feature: Moderates group content
  In order to moderate content of a group
  As a member of the council with moderation enabled
  I want to moderate the group's content 
  And I want to not be able to moderate other groups content.

Background:
  Given I exist
  And a group exists
  And I am a member of that group
  And that group has a council
  And that council has admins moderate content
  And I am a member of that council
  And I am logged in
  And I am on that group's landing page

Scenario: I can see the moderation tab
  Then I should see "Moderation"

Scenario: Moderation tab should have all sections
  Given I am on the moderation panel
  Then I should see "Page Moderation"
  And I should see "Comment Moderation"
  And I should see "Chat Moderation"

Scenario: I should see moderated pages of my group
  Given a wiki_page: "smelly" exists with title: "Smelly Content", site: that site
  And that group has admin access to that wiki_page
  And a post: "clean" comments that wiki_page with body: "Non Smelly Post"
  And a moderated_flag exists with flagged: that wiki_page
  And I am on the moderation panel
  Then I should see "Smelly Content"
  When I follow "Comment Moderation"
  Then I should see "There are no pages for this view"

Scenario: I should not see moderated pages if they are not for my group
  Given a page: "others-smell" exists with title: "Smelly Others", site: that site
  And a moderated_flag exists with flagged: that page
  And I am on the moderation panel
  Then I should not see "Smelly Others"

Scenario: I should see moderated posts of my group
  Given a page: "clean" exists with title: "Clean Content", site: that site
  And that group has admin access to that page
  And a post: "smelly" comments that page with body: "Smelly Post"
  And a moderated_flag exists with flagged: that post
  And I am on the moderation panel
  And I follow "Comment Moderation"
  Then I should see "Smelly Post"

Scenario: I should not see moderated posts of other groups
  Given a page: "others" exists with title: "Others Content", site: that site
  And a post: "smelly" comments that page with body: "Others Smelly Post"
  And a moderated_flag exists with flagged: that post
  And I am on the moderation panel
  And I follow "Comment Moderation"
  Then I should not see "Others Smelly Post"
