Feature: Manage campaigns
  In order to track the progress of company goals
  As a user
  I want to manage campaigns

  Scenario: Creating a campaign
    Given I am registered and logged in as annika
    And I am on the campaigns page
    When I follow "+Add Campaign"
    Then I should see "Add Campaign"

    When I fill in "Name" with "Generate 100 leads this month"
    And I fill in "Start date" with "1/12/2010"
    And I fill in "End date" with "31/12/2010"
    And I press "Save Campaign"

    Then I should be on the campaigns page
    And I should see "Campaign was successfully created"

  Scenario: Viewing list of campaigns
    Given I am registered and logged in as annika
    And a campaign exists with name: "Generate 100 leads this month", start_date: "1/12/2010", end_date: "31/12/2010"

    When I follow "Campaigns" within "#navigation"
    Then I should see "Generate 100 leads this month"
    And I should see "Dec 01 - Dec 31"

  Scenario: Viewing a campaign
    Given I am registered and logged in as annika
    And a campaign exists with name: "Generate 100 leads this month", start_date: "1/12/2010", end_date: "31/12/2010"
    And I am on the campaigns page

    When I follow "Generate 100 leads this month"
    Then I should see "Generate 100 leads this month"
    And I should see "Dec 01 - Dec 31"

  Scenario: Editing a campaign
    Given I am registered and logged in as annika
    And the campaign exists with name: "Generate 100 leads this month", start_date: "1/12/2010", end_date: "31/12/2010"
    And I am on that campaign's page

    When I follow "Edit"
    Then I should be on that campaign's edit page
    Then I should see "Edit Campaign"

    When I fill in "Name" with "Generate 20 leads next week"
    And I fill in "Start date" with "8/12/2010"
    And I fill in "End date" with "15/12/2010"
    And I follow "Save Campaign"
    Then I should be on that campaign's page
    And I should see "Campaign was successfully updated"
    And I should see "Generate 20 leads next week"
    And I should see "Dec 08 - Dec 15"
