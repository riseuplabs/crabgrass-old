Feature: Only members of a group can destroy or propose to destroy groups.
  In order to remove an inactive, a hijacked or an old group
  As a member of a group
  I want to destroy that group. Others should not be able to destroy it.

Background:
  Given a group exists
  And I exist
  And I am logged in

@dev
Scenario: The only member should see the destroy link
  Given I am a member of that group
  When I go to that group's landing page
  Then I should see "Destroy Group"


