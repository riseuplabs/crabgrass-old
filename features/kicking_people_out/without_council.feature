Feature: Remove users from a group without a council
  In order to get rid of inactive or disruptive group members and not allow abusive members to kick out good members
  As a member of a group
  I want (for now) that no one is able to kick in anyone out to prevent worse abuse
Background:
  Given a group exists

  And I exists with display_name: "Periwinkle!"
  And the following users exist:
    | user    | display_name |
    | red     | Red!         |
    | blue    | Blue!        |
    | gerrard | Gerrard      |
    | parsons | Parsons      |

  And that group has the following members:
    | user    |
    | red     |
    | blue    |
    | gerrard |
    | parsons |
    | me      |


  And I am logged in

Scenario: I can't kick anyone out
  When I go to that group's membership list page

  Then I should see "Red" within user: "red"'s row
  And I should see "Coordinator" within user: "red"'s row
  And I should see "Coordinator" within my row

  And I should not see "Remove" within user: "red"'s row
  And I should not see "Remove" within user: "parsons"'s row
  And I should not see "Remove" within my row

# @js
# Scenario: Proposing to kick out a user requires confirmation
#
# Scenario: I create a proposal to kick someone out
#
# Scenario: Almost all of the group members vote 'approve' the proposal. It takes effect immediately.
#
# Scenario: After one week over or exactly 2/3 of the cast votes are to 'approve'. The unlucky user gets removed.
#
# Scenario: Nearly all group members vote to 'reject' the proposal. The proposal gets rejected immediately.
#
# Scenario: After one week less than 2/3 of the cast votes are to 'approve'. The proposal gets rejected.
#
