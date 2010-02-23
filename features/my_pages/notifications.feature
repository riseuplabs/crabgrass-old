Feature: The my_work and all_pages feeds shows notifications with the pages
  In order to stay informed if people notify me
  As a logged in user
  I want to be able to see my notifications and the corresponding messages
  And I want to not see other peoples notifications and removed notifications

Background:
  Given I exist
  And a page: "interesting" exists with title: "This is interesting stuff!"
  And I have admin access to that page

Scenario: I can't see the page without notification
  Given a user: "sender" exists with display_name: "I notify others"
  And that user has admin access to that page
  And a user "notified" exists with display_name: "Me can haz notified"
  And the user: "sender" notified the user: "notified" about that page with message: "check this out!"
  When I am logged in
  And I am on my work page
  Then I should not see "This is interesting stuff!"

Scenario: I can see notifications and messages on my work
  Given a post comments that page with user: the user: "me", body: "Here's what I got to say..."
  And a user: "commie" exists with display_name: "Commander Commenter"
  And that user has admin access to that page
  And that user notified me about that page with message: "Comments in the house"
  And I am logged in
  When I am on my work page
  Then I should see "Comments in the house"
  And I should see that user's login
  When I am on my all pages page
  Then I should see "Comments in the house"
  And I should see that user's login

Scenario: I can see Pages I was notified of and the messages on all pages
  Given a user: "early" exists with display_name: "Early Bird"
  And that user has admin access to that page
  And a user "yan" exists with display_name: "Yet another notifier"
  And that user has admin access to that page
  And the user: "early" notified me about that page with message: "check this out!"
  And the user: "yan" notified me about that page with message: "yet another notification"
  And I am logged in
  When I am on my all pages page
  Then I should see "This is interesting stuff!"
  And I should see the user: "early"'s login
  And I should see "check this out!"
  And I should see the user: "yan"'s login
  And I should see "yet another notification"
  When I am on my work page
  Then I should not see "check this out!"
  And I should not see the user: "early"'s login


