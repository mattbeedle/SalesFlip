Feature: Manage Opportunity Stages Administration
  In order to customize the application to fit their own sales pipeline
  As an administrator
  I want to manage opportunity stages

  Scenario: Adding an opportunity stage
    Given I am registered and logged in as Matt
    And I am on the root page
    When I follow "Administration"
    And I follow "Add Opportunity Stage"
    And I fill in "Name" with "Infomail Sent"
    And I fill in "Percentage" with "10"
    And I fill in "Notes" with "These are some notes about the stage"
    And I press "Create Opportunity stage"
    Then I should be on the administration root page
    And I should see "Infomail Sent"
    And I should see "10%"
    And I should see "These are some notes about the stage"
    And 1 opportunity stages should exist with percentage: 10, notes: "These are some notes about the stage"

  Scenario: Removing an opportunity stage
    Given I am registered and logged in as Matt
    And I am on the root page
    And there is only 1 opportunity stage
    When I follow "Administration"
    And I follow "Delete"
    And I press "Delete"
    Then I should be on the administration root page
    And the opportunity stage should have been deleted
