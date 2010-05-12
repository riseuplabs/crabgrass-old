Feature: Social Activites Dropdown
  In order to see recent social activity
  As a logged in user
  There is an icon in the global nav that shows a count of recent social activity
  And I can click on that icon to see recent social activity

Scenario: social activity icon updates when social activity occurs
  Given I am logged in
  And I have a friend 'red'
  And there is an open group 'prism'
  When 'red' joins that group
  Then my social activity list should update
