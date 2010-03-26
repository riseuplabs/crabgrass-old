Feature: List Group Tasks
  In order to view group tasks
  I navigate to group tasks
  Then I can choose pending or completed tasks

Background:
  Given a group: "rainbow" exist with name: "Rainbow"
  And a user: "blue" exists with display_name: "Blue", id: 1000
  And that user is a member of that group
  And I am logged in as that user
  And I am on that group's landing page
  And I follow "Tasks"

Scenario: View menu options 
  Then I should see "Pending"
  And I should see "Completed"

#Scenario: View pending tasks
#  When I follow "Pending"
#  Then I should see "pending task"
#  And I should not see "completed task"
