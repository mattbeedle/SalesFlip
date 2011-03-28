Feature: Admin manages duplicate leads

  Scenario:
    Given I am registered and logged in as Matt
    And a lead "primary" exists with company: "Widgets GmbH"
    And a lead "duplicate" exists with company: "widgets gmbh", duplicate: true
    When I go to the administration duplicates page
    Then I should see "widgets gmbh"

    When I follow "widgets gmbh"
    And I choose "Widgets GmbH"
    When I press "Merge"
    Then I should be on the administration duplicates page
    And I should not see "widgets gmbh"

  Scenario: moving comments
    Given I am registered and logged in as Matt
    And a lead "primary" exists with company: "Widgets GmbH"
    And a lead "duplicate" exists with company: "widgets gmbh", duplicate: true
    And a comment exists with text: "My Comment", commentable: lead "duplicate"
    And I go to the administration duplicates page
    And I follow "widgets gmbh"
    And I choose "Widgets GmbH"
    When I press "Merge"
    Then the comment should be in the lead "primary"'s comments

  Scenario: moving tasks
    Given I am registered and logged in as Matt
    And a lead "primary" exists with company: "Widgets GmbH"
    And a lead "duplicate" exists with company: "widgets gmbh", duplicate: true
    And a task exists with asset: lead "duplicate"
    And I go to the administration duplicates page
    And I follow "widgets gmbh"
    And I choose "Widgets GmbH"
    When I press "Merge"
    Then the task should be in the lead "primary"'s tasks

  Scenario: moving and reassigning tasks
    Given I am registered and logged in as Matt
    And a user exists
    And a lead "primary" exists with company: "Widgets GmbH", assignee: user
    And a lead "duplicate" exists with company: "widgets gmbh", duplicate: true
    And a task exists with asset: lead "duplicate"
    And I go to the administration duplicates page
    And I follow "widgets gmbh"
    And I choose "Widgets GmbH"
    And I check "Assign tasks to owner of new lead"
    When I press "Merge"
    Then the user should be the task's assignee

  Scenario: not a duplicate
    Given I am registered and logged in as Matt
    And a lead exists with company: "Widgets GmbH", duplicate: true
    And a lead exists with company: "Widgets AG"
    And I go to the administration duplicates page
    And I follow "Widgets GmbH"
    And I follow "Not a Duplicate?"
    Then I should be on the administration duplicates page
    And I should not see "Widgets GmbH"
