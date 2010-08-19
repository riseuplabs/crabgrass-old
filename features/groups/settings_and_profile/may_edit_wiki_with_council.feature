Feature: Council can restrict editing of group wiki to council

Background:
  Given a group exists
  And that group has a council
  And a user: "fuscia" exists with display_name: "Fuscia"
  And I exist
  And I am logged in
  And I am a member of that group
  And user: "fuscia" is a member of that group

Scenario: With the default settings, members should be able to see the edit wiki link
  When I go to that group's landing page
  Then I should see "Edit" within "#wiki-area"

Scenario: When there is a council, as a member of that council I can change the group wiki settings 
  Given I am a member of that council
  When I go to that group's administration page
  And I follow "Permissions"
  Then I should see "Group Wiki"
  When I uncheck "profile_members_may_edit_wiki"
  And I press "Save"
  Then I should see "Changes saved"
  When I go to that group's landing page
  Then I should see "Edit" within "#wiki-area"
  When I am not logged in
  And I am logged in as user: "fuscia"
  And I go to that group's landing page
  Then I should not see "Edit" within "#wiki-area"
