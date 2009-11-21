Feature: Moderation settings for group
  In order to configure moderation per group
  As a member of the group and it's council if it exists
  I want to configure the moderation setting

Background:
  Given I exist
  And a group exists
  And I am a member of that group
  And I am logged in
  And I am on that group's landing page

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
  And that group should not have admins moderate content
  And the "moderate content" checkbox should not be checked

Scenario: Moderation checkbox for group without council disabled
  When I follow "Edit Settings"
  And I follow "Permissions"
  Then I should see "Allow Admins to moderate the groups content"
  And that group should not have admins moderate content
  And the "moderate content" checkbox should be disabled

Scenario: Moderation for group with council can be enabled
  Given that group has a council
  And I am a member of that council
  When I follow "Edit Settings"
  And I follow "Permissions"
  And I check "Allow Admins to moderate the groups content"
  And I press "Save"
  Then that group should have admins moderate content
  And the "moderate content" ckeckbox should be checked
  And I should see "Moderation"
