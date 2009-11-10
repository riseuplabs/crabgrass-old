Feature: Destroying groups
  In order to remove an inactive, a hijacked or an old group
  As a member of that group
  I want to destroy that group and I want to not be able to easily destroy groups used by other people.

  Background:
    Given a group: "rainbow" exist
    And a user: "blue" exists
    And that user is a member of that group
    And I am logged in as that user
    And I am on the group's page

  Scenario: Destroy a group when I am the only member
    When I follow "Destroy Group"
    Then I should be on my dashboard page
    And I should see "Group Destroyed"
    And that group should not exist

  Scenario: Destroy a group when I am the only member of the council
    Given that group has a council
    And I am a member of that group's council
    And a user: "red" is a member of that group
    When I go to that group's council page
    And I follow the "Destroy Group" link
    Then I should be on my dashboard page
    And that group should not exists

  Scenario: Destroying a group with many inactive members is not immediate
    Given that group has 5 members
    When I follow "Propose to destroy this group"
    And I press "Destroy"
    Then I should be on the group's page
    And I should not see "Propose to destroy this group"

  Scenario: Destroying a group with many inactive members takes 1 month
    Given that group has 5 members
    When I follow "Propose to destroy this group"
    And I press "Destroy"
    And I wait 1 month
    Then that group should not exist

  Scenario: Destroying a group with many inactive members can be vetoed
    Given that group has 5 members
    And the group has been proposed to destroy
    And I am on my group destruction proposals page
    When I follow "reject"
    And I wait 1 month
    And I go to the group page
    Then I should see "Propose to destroy this group"

