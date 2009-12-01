Feature: Destroying groups that several members and no council
  In order to remove an inactive, a hijacked or an old group
  As one of several members of that group
  I want to be able to propose to other members to destroy the group

Background:
  Given a group: "rainbow" exist with full_name: "Rainbow"
  And I exist with display_name: "Blue"
  And I am a member of that group
  And that group has 5 other members
  And I am logged in
  Given I am on that group's landing page

@js
Scenario: Proposing to destroy the group requires confirmation
  When I follow "Propose to Destroy Group"
  Then I should see "Are you sure you want to propose to delete this group?"

Scenario: I propose to destroy the group. The proposal becomes active and I get notified by email
  When I follow and confirm "Propose to Destroy Group"
  Then I should be on the group's landing page
  And I should not see "Propose to Destroy Group"
  And I should see "Your proposal to destroy this group has been sent to the groups members. If this proposal is not vetoed in a month, this group will be destroyed."
  And I should receive an email with subject: "Blue has proposed to destroy group Rainbow!"

Scenario: The proposal can be vetoed (rejected) within a month.
  Given I have proposed to destroy that group
  And I am on my requests page
  When I follow "reject"
  And I wait 1 month
  And I go to that group's landing page
  Then I should see "Propose to Destroy Group"

Scenario: No one rejects the proposal within one month. The group gets deleted.
  When I follow and confirm "Propose to Destroy Group"
  And I wait 1 month
  Then that group should not exist
  And I should receive an email with subject: "Group Rainbow has been deleted by Blue!"
  # And I should receive an email with body containing a destroyed groups directory link

Scenario: Less than 2/3 of votes are approvals for the proposal within one month. The group is not deleted.
  When I follow and confirm "Propose to Destroy Group"
  And the 1st user approves the proposal to destroy that group
  And the 2nd user rejects the proposal to destroy that group
  And the 3rd user rejects the proposal to destroy that group
  And I wait 1 month
  And I go to that group's landing page
  Then I should see "Propose to Destroy Group"

Scenario: More than 2/3 of votes are approvals for the proposal within one month. The group gets deleted.
  When I follow and confirm "Propose to Destroy Group"
  And the 1st user approves the proposal to destroy that group
  And the 2nd user approves the proposal to destroy that group
  And the 3rd user rejects the proposal to destroy that group
  And I wait 1 month
  Then that group should not exist
  And I should receive an email with subject: "Group Rainbow has been deleted by Blue!"
  # And I should receive an email with body containing a destroyed groups directory link