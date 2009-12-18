Feature: Destroying groups that has a council with several members
  In order to remove an inactive, a hijacked or an old group
  As one of several members of the council
  I want to be able to propose to other council members to destroy the group

Background:
  Given a group: "rainbow" exist with full_name: "Rainbow"
  And that group has a council
  And I exist with display_name: "Blue"

  Given that group has 3 members
  And I am a member of that group
  And that council has 3 members
  And I am a member of that council


  Given I am logged in
  And I am on the group's landing page

Scenario: I propose to destroy the group
  When I follow and confirm "Propose to Destroy Group"
  Then I should be on the group's landing page
  And I should not see "Propose to Destroy Group"
  And I should see "Your proposal to destroy this group has been sent to the groups members. If this proposal is not vetoed in a month, this group will be destroyed."
  And I should receive an email with subject: "Blue has proposed to destroy group Rainbow!"

Scenario: Group has many members, but with near unanimous council approval it will get deleted immediately
  When I follow and confirm "Propose to Destroy Group"
  And the 4th user approves the proposal to destroy that group
  And the 5th user approves the proposal to destroy that group
  And the 6th user approves the proposal to destroy that group
  Then that group should not exist
  And I should receive an email with subject: "Group Rainbow has been deleted by Blue!"


Scenario: Non-council members can not vote on the proposal
  Given I have proposed to destroy that group
  And user: "red" exists
  And user: "red" is a member of that group
  And I am logged in as that user
  And I go to my requests page
  Then I should not see /Blue has proposed to destroy group Rainbow\s*pending\s*approve \| reject/

Scenario: Council members can vote on the proposal
  Given I have proposed to destroy that group
  And user: "red" exists
  And that user is a member of that group
  And that user is a member of that council
  And I am logged in as that user
  And I go to my requests page
  Then I should see /Blue has proposed to destroy group Rainbow\s*pending\s*approve \| reject/

Scenario: Non-council members should receive proposal and deletion notification emails
  Given user: "red" exists
  And that user is a member of that group
  When I follow and confirm "Propose to Destroy Group"
  And I wait 1 month
  Then that group should not exist
  And that user should receive an email with subject: "Blue has proposed to destroy group Rainbow!"
  And that user should receive an email with subject: "Group Rainbow has been deleted by Blue!"
