@plain
Feature: View People in Group
  In order to view the people in a group
  I can either:
  Go to that group's people page or,
  Go to that group's administration membership page.
  And I can see People according to letter. 

Background:
  Given a group: "diggers" exists with name: "diggers"
  And the following users exist:
    | user    | display_name | login   |
    | red     | Red!         | red     |
    | gerrard | Gerrard      | gerrard |
    | parsons | Parsons      | parsons |
    | blue    | Blue!        | blue    |

  And that group has the following members:
    | user    |
    | red     |
    | gerrard |
    | parsons |
    | blue    |

  And I am logged in as user: "blue"

Scenario: View list of people
  When I go to group: "diggers"'s people page
  Then I should see "Red!"
  And I should see "Gerrard"
  And I should see "Parsons"
  And I should see "Blue!"

Scenario: Follow letter pagination links
  When I go to group: "diggers"'s people page
  Then show me the page
  And I follow "R" within ".letter_pagination"
  Then I should see "Red!"
  And I should not see "Gerrard"
  And I follow "All" within ".letter_pagination"
  Then I should see "Red!"
  And I should see "Gerrard"

Scenario: View Memberships in administration
  When I go to group: "diggers"'s administration page
  And I follow "Members"
  Then I should see "Red!"
  And I should see "Parsons"
  When I follow "R" within ".letter_pagination"
  Then I should see "Red!"
  And I should not see "Parsons"
