Feature: Moderation for group content
  In order to moderate content of a group
  As a member of the council with moderation enabled
  I want to moderate the group's content 
  And I want to not be able to moderate other groups content.

Background:
  Given a group: "my_group" exists
  And a user exists
  And that user is a member of that group
  And I am logged in as that user
  And I am on the group's landing page

Scenario: The group does not have a council so i can not see the moderation tab
  Then I should not see "Moderation"

Scenario: I am part not part of the groups council so i can not see the moderation tab
  Given that group has a council
  Then I should not see "Moderation"

Scenario: Moderation for the group has not been enabled so i can not see the moderation tab
  Given that group has a council
  And I am a member of that council
  Then I should not see "Moderation"

Scenario: Moderation for group with council not enabled by default
  Given that group has a council
  And I am a member of that council
  When I follow "Edit Settings"
  And I follow "Permissions"
  Then I should see "Allow Admins to moderate the groups content"
  And that group should not have admins_moderate_content
  And the "moderate content" checkbox should not be checked

Scenario: Moderation checkbox for group without council disabled
  When I follow "Edit Settings"
  And I follow "Permissions"
  Then I should see "Allow Admins to moderate the groups content"
  And that group should not have admins_moderate_content
  And the "moderate content" checkbox should be disabled

Scenario: Moderation for group with council can be enabled
  Given I am an admin of that group
  And I am on that group's permissions page
  And I check "Allow Admins to moderate the groups content"
  And I press "Save"
  Then that group should have admins_moderate_content
  And the "moderate content" ckeckbox should be checked
  And I should see "Moderation"

Scenario: Group Moderator should see Moderation menu item
  Given I am a moderator of that group
  And I am on that group's permissions page
  Then I should see "Moderation"
  And that group should have admins_moderate_content
  And the "moderate content" checkbox should be checked

Scenario: Moderation tab should have all sections
  Given I am a moderator of that group
  And I am on the moderation panel
  Then I should see "Page Moderation"
  And I should see "Comment Moderation"
  And I should see "Chat Moderation"

Scenario: Moderation tab should have all sections
  Given I am a moderator of that group
  And I am on the moderation panel
  And a page: "smelly" exists with title "Smelly Content"
  And that group owns that page
  And a flagged_page exists with page: that page, reason: "language"
  And I follow "Page Moderation"
  Then I should see "Smelly Content"
