Feature: Remove users from a group without a council
  In order to get rid of inactive or disruptive group members and not allow abusive council members to kick out good members
  As a member of a group's council
  I want to be able to remove other group members and council members

Background:
  Given a group exists with name: "diggers"
  And that group has a council

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

  And that council has the following members:
    | user    |
    | red     |
    | parsons |

  And I am logged in

Scenario: I may kick out anyone as a council member
  Given I am a member of the council
  When I go to that group's membership review page
  And I should see "Remove" within user: "blue"'s row
  And I should see "Remove" within user: "gerrard"'s row
#  And I should see "Remove" within user: "red"'s row
#  And I should see "Remove" within user: "parsons"'s row

Scenario: I can't kick myself out
  Given I am a member of the council
  When I go to that group's membership review page
  Then I should see "Periwinkle" within my row
  And I should not see "Remove" within my row

Scenario: I can't kick anyone out if I am not a council member
  When I go to that group's membership review page
  And I should not see "Remove" within user: "red"'s row
  And I should not see "Remove" within user: "gerrard"'s row

Scenario: I remove a non-council users from the group
  Given I am a member of the council
  When I go to that group's membership review page
  And I follow and confirm "Remove" within user: "gerrard"'s row
  Then I should be on that group's membership review page
  And I should see "Gerrard has been removed from group diggers"
  And I should not see "Gerrard" within the members table

@js
Scenario: Clicking 'Remove' for regular user (non-coordinator) shows a confirmation dialog
  Given I am a member of the council
  When I go to that group's membership review page
  And I follow "Remove" within user: "gerrard"'s row
  Then I should see "Are you sure you want to remove 'Gerrard' from the group?"

@js
Scenario: Clicking 'Remove' for another coordinator (council-member) shows proposal to remove dialog
  Given I am a member of the council
  When I go to that group's membership review page
  And I follow "Remove" within user: "red"'s row
  Then I should see "This member is also a member of the council. Do you want to propose to remove 'Red'?"

@dev
Scenario: I create a propose to remove another council member
  Given I am a member of the council
  When I go to that group's membership review page
  And I follow and confirm "Remove" within user: "red"'s row
  Then I should not see "Remove" within user: "red"'s row
  And I should see "You have proposed to remove user Red! who is also a member of the council. To remove a coordinator (council-member) two thirds of all coordinators need to approve this."
  And I should see "Removal Requested" within user: "red"'s row



# Scenario: I remove another council member from the group
#   Given I am a member of the council
#   When I go to that group's membership review page
#   And I follow and confirm "Remove" within user: "red"'s row
#   Then I should be on that group's membership list page
#   And user: "red" should not be a member of that group
#   And I should not see "Remove" within user: "red"'s row
#
# Scenario: I remove another group member from the group
#   Given I am a member of the council
#   When I go to that group's membership review page
#   And I follow and confirm "Remove" within user: "gerrard"'s row
#   Then I should be on that group's membership list page
#   And user: "gerrard" should not be a member of that group
#   And I should not see "Gerrard"
#

