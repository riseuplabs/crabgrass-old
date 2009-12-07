Feature: Remove users from a group without a council
  In order to get rid of inactive or disruptive group members and not allow abusive members to kick out good members
  As a member of a group
  I want to be able to propose to remove them and they should get removed when other members agree

Background:
  Given a group exists
  And I exists with display_name: "Periwinkle!"
  And user: "troll" exists with display_name: "Popular Troll"

  Given I am a member of that group
  And user: "troll" is a member of that group
  And that group has 5 other members

  Given I am logged in
  And I am on that group's membership list page

Scenario: I can't propose to kick myself out
  Then show me the page
  Then I should see "Periwinkle! Today Coordinator"
  And I should not see "Periwinkle! Today Coordinator propose to remove"

@js
Scenario: Proposing to kick out a user requires confirmation

Scenario: I create a proposal to kick someone out

Scenario: Almost all of the group members vote 'approve' the proposal. It takes effect immediately.

Scenario: After one week over or exactly 2/3 of the cast votes are to 'approve'. The unlucky user gets removed.

Scenario: Nearly all group members vote to 'reject' the proposal. The proposal gets rejected immediately.

Scenario: After one week less than 2/3 of the cast votes are to 'approve'. The proposal gets rejected.

