@plain
Feature: Groups have a Wiki on the landing page
  In order to get a quick overview over a groups interests
  As a visitor to the groups landing page
  I can see a preview of that groups wiki
  And I can expand that preview to see the whole wiki

Background:
  Given a wiki: "group wiki" exists
  And a group: "rainbow" exists with name: "Rainbow"
  And a public profile exists with entity: that group, wiki: that wiki
  And I exist
  And I am a member of that group
  And I am logged in
  And I am on that group's landing page

Scenario: Seeing the folded wiki
  Then I should see that wiki's preview_html rendered
  And I should not see that wiki's body_html rendered
  And I should see "more" within #group-wiki
  And I should see "Edit" within #group-wiki

@js
Scenario: Expanding the wiki
  Then I should see that wiki's preview_html rendered
  And I should not see that wiki's body_html rendered
  When I follow "more" within #group-wiki
  And I wait for the AJAX call to finish
  Then I should see that wiki's body_html rendered
  And I should not see that wiki's preview_html rendered
  And I should not see "more" within #group-wiki
  And I should see "Edit" within #group-wiki
