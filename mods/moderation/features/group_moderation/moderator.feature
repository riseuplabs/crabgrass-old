Feature: Moderation for group content
  In order to moderate content of a group
  As a member of the council with moderation enabled
  I want to moderate the group's content 
  And I want to not be able to moderate other groups content.

Background:
  Given I exist
  And a group exists
  And that group has admins moderate content
  And I am a member of that group
  And that group has a council
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

Scenario: I should see moderated pages
  Given a page: "smelly" exists with title: "Smelly Content", site: that site
  And that group has admin access to that page
  And a moderated_page exists with page: that page
  And I am on the moderation panel
  Then I should see "Smelly Content"

Scenario: I should see moderated posts
  Given a page: "clean" exists with title: "Clean Content", site: that site
  And that group has admin access to that page
  And a post: "smelly" comments that page with body: "Smelly Post"
  And a moderated_post exists with post: that post
  And I am on the moderation panel
  And I follow "Comment Moderation"
  Then I should see "Smelly Post"
