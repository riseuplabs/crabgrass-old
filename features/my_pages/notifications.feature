Feature: The "Notifications" feed shows pages I have been notified of
  In order to stay informed if people notify me
  As a logged in user
  I want to be able to see my notifications and the corresponding messages
  And I want to not see other peoples notifications and removed notifications

Background:
  Given I exist
  And a page: "interesting" exists with title: "This is interesting stuff!"
  And I have view access to that page

Scenario: I can't see the page without notification
  Given a user: "sender" exists with display_name: "I notify others"
  And a user "notified" exists with display_name: "Me can haz notified"
  And the user: "early" notified the user: "notified" about that page with message: "check this out!"
  When I am logged in
  And I am on my notifications page
  Then I should not see "This is interesting stuff!"

Scenario: I can see Pages I was notified of and the messages
  Given a user: "early" exists with display_name: "Early Bird"
  And a user "yan" exists with display_name: "Yet another notifier"
  And the user: "early" notified me about that page with message: "check this out!"
  And the user: "yan" notified me about that page with message: "yet another notification"
  And I am logged in
  When I am on my notifications page
  Then I should see "This is interesting stuff!"
  And I should see the user: "early"'s display_name
  And I should see the user: "yan"'s display_name
  And I should see "check this out!"
  And I should see "yet another notification"


