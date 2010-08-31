@js

Feature: When the edit wiki icon is visible, the wiki can actually be edited

Background:
  Given a group exists
  And I exist
  And I am logged in
  And I am a member of that group

Scenario: I can edit the group wiki
  And I go to that group's landing page
  When I follow "Edit"
  And I wait for the AJAX call to finish
  Then I should see "Close Editor"
  And I follow "Close Editor"
  And I wait for the AJAX call to finish
  Then I should not see "Close Editor"
