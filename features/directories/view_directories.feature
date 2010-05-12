Feature: View all directories
  As a logged in user with no groups, networks, or friends
  When I go to directories, I should land on All Groups/Networks/People tab
  As a logged in user with groups, networks, and friends
  When I go to directories, I should land on My Groups/Networks/People tab

Background:
  Given I exist
  And I am logged in

Scenario: User with no groups, networks, or friends
  When I follow "GROUPS"
  Then I should be on the group directory
  When I follow "NETWORKS"
  Then I should be on the network directory
  When I follow "PEOPLE"
  Then I should be on the people directory 

Scenario: User with groups and networks
  Given a group: "rainbow" exists with name: "rainbow"
  And a network: "floo network" exists with name: "floo_network"
  When I follow "GROUPS"
  Then I should be on the my groups directory
  When I follow "NETWORKS"
  Then I should be on the my networks directory
