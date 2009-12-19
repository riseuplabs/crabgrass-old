Feature: Short cut to create open job descriptions
  In order to let people know I have an open position
  As a user who knows about a job opportunity
  I want to be able to create a page for that job easily
    And I want that page to show up in the job search

Background:
  Given I exist
    And a site: mru with name: "mru" exists
    And a site: unido with name: "unido" exists

Scenario: Short cut does not show up on unido site
  Given we are on the site: unido
  When I go to the site home
  Then I should not see "Add a job opportunity"

Scenario: Short cut exists on mru site
  Given we are on the site: mru
  When I go to the site home
  Then I should see "Add a job opportunity"

Scenario I add a job opportunity
  Given we are on the site: mru
  When I got to the site home
    And I follow "Add a job opportunity"
  Then I should be on the wiki create page
    And Title should be filled with: "Job Opportunity: (please fill out)"
    And Summary should be filled with: "Location: (please fill out)\nDescription: (please fill out)"
    And Tags should be filled with: "job, jobs, jobsearch, employment"

Scenario Added job opportunity shows in list of jobs
  Given we are on the site: mru
    And the site network's wiki contains "[Job opportunities->/me/search?q=job]"
  When I go to the site home
    And I follow "Add a job opportunity"
    And I fill Titel with "This is my brand new job offer!"
    And I press "Create Page"
    And I press "Save"
    And I go to the site home
    And I follow "Job opportunities"
  Then I should see "This is my brand new job offer!" in the page list
