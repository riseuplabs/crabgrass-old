# Feature: Only members of a group can destroy or propose to destroy groups.
#   In order to remove an inactive, a hijacked or an old group
#   As a member of a group
#   I want to destroy that group. Others should not be able to destroy it.
#
# Background:
#   Given a group exists
#   And I exist
#   And I am logged in
#
# Scenario: The only member in the group sees the destroy link and no destroy proposal link
#   Given I am a member of that group
#   When I go to that group's administration page
#   Then I should see "Destroy Group"
#   Then I should not see "Propose to Destroy Group"
#
# Scenario: A member of a group with many other members sees the destroy proposal link and not direct destroy link
#   Given I am a member of that group
#   And that group has 5 other members
#   When I go to that group's administration page
#   Then I should not see /\n\s*Destroy Group/
#   Then I should see /\n\s*Propose to Destroy Group/
#
# Scenario: A nonmember of a group with one member doesn't see any destroy links
#   Given that group has 1 other members
#   When I go to that group's administration page
#   Then I should not see "Destroy Group"
#   Then I should not see "Propose to Destroy Group"
#
# Scenario: A nonmember of a group with many members doesn't see any destroy links
#   Given that group has 5 other members
#   When I go to that group's administration page
#   Then I should not see "Destroy Group"
#   Then I should not see "Propose to Destroy Group"
