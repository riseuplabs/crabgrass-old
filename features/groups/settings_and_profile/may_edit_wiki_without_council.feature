Feature: With no council, all group members can edit wiki
  And there is no option to change the wiki permissions in the group admin 

Background:
  Given a group exists
  And I exist
  And I am logged in

Scenario: Logged in users who are not members of the group cannot see the edit wiki link
  When I go to that group's landing page
  Then I should not see "Edit" within '#wiki-area'

Scenario: When there is no council, the edit group wiki checkbox is not shown 
  When I am a member of that group
  And I go to that group's administration page
  And I follow "Permissions"
  Then I should not see "Group Wiki"

Scenario: I can edit the group wiki
  When I am a member of that group
  And I go to that group's landing page
  Then I should see "Edit" within '#wiki-area'
