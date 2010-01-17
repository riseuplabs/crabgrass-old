Feature: Moderation for posts workflow
  In order to moderate posts
  As a member of a groups council with moderation enabled
  I want to veto moderation and delete posts
  And I want to list all posts with pagination

Background:
  Given I exist
  And a group exists
  And I am a member of that group
  And that group has a council
  And that council has admins moderate content
  And I am a member of that council
  And I am logged in
  And I am on the moderation panel
  And a page: "clean" exists with title: "Clean Content", site: that site
  And that group has admin access to that page

Scenario: I should see no moderated posts to start with
  When I follow "Comment Moderation"
  Then I should see "There are no pages for this view"

Scenario: I should see all posts on the "all" tab with pagination
  Given a post: "last" comments that page with body: "D'oh the last one again."
  Given 40 Posts comment that page
  Given a post: "first" comments that page with body: "I am the first!"
  When I follow "Comment Moderation"
  And I follow "See All Posts"
  Then I should see "I am the first!"
  And I follow "Next »"
  Then I should see "D'oh the last one again."

Scenario: I should only see new moderated posts in new
  Given a post: "smelly" comments that page with body: "Smelly Post"
  And a moderated_flag exists with flagged: that post
  When I follow "Comment Moderation"
  Then I should see "Smelly Post"
  When I follow "vetted"
  Then I should see "There are no pages for this view"
  When I follow "deleted"
  Then I should see "There are no pages for this view"
