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

Scenario: Moderation checkbox for group without council disabled
  When I follow "Edit Settings"
  And I follow "Permissions"
  Then I should not see "Moderation"
  And I should not see "Allow council members to moderate the content of the group"
  # And that group should not have admins moderate content

Scenario: Moderation for the group has not been enabled so i can not see the moderation tab
  Given that group has a council
  And I am a member of that council
  Then I should not see "Moderation"
  And I should not see "Allow council members to moderate the content of the group"

Scenario: Moderation for group with council not enabled by default
  Given that group has a council
  And I am a member of that council
  When I am on that council's landing page
  And I follow "Edit Settings"
  And I follow "Permissions"
  Then I should see "Allow council members to moderate the content of the group"
  # And that group should not have admins moderate content
  And the "Allow council members to moderate the content of the group" checkbox should not be checked

Scenario: Moderation for group with council can be enabled
  Given that group has a council
  And I am a member of that council
  When I am on that council's landing page
  And I follow "Edit Settings"
  And I follow "Permissions"
  And I check "Allow council members to moderate the content of the group"
  And I press "Save"
  Then I should see "Moderation"

Scenario: Moderation for group with council can be disabled
  Given that group has a council
  And I am a member of that council
  And that council has admins moderate content
  When I am on that council's landing page
  And I follow "Edit Settings"
  And I follow "Permissions"
  Then the "Allow council members to moderate the content of the group" checkbox should be checked
  And I should see "Moderation"
  When I uncheck "Allow council members to moderate the content of the group"
  And I press "Save"
  Then the "Allow council members to moderate the content of the group" checkbox should not be checked
  And I should not see "Moderation" in the main menu
