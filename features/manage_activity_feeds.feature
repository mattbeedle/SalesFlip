Feature: Manage activity feeds
  In order to keep track of what has been done, and easily manage related items
  A User
  wants to keep an activity history of related contacts, tasks and comments
  
  Background:
    Given I am registered and logged in as annika
    And account: "careermee" exists with user: Annika
    
  Scenario: Viewing contact history feed
    Given I am on the account's page
    When I add a contact
    Then I should see "Contact" within "#recent_activity"
  
  Scenario: Viewing task history feed
    Given I am on the account's page
    When I add a task
    Then I should see "Task" within "#recent_activity"
    And I should see "Make these features pass" within "#recent_activity"
  
  Scenario: Completing a task from the history feed
    Given I am on the account's page
    When I add a task
    And I check "Make these features pass" within "#recent_activity"
    And I press "activity_task_submit"
    Then I should not see "Make these features pass" within "#main"
    
  Scenario: Viewing comment history feed
    Given I am on the account's page
    When I add a comment
    Then I should see "Comment" within "#recent_activity"
    And I should see "This is pretty cool" within "#recent_activity"
