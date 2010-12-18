Feature: Manage Administration
  In order to customize the application
  As an administrator
  I want to use the administration interface

  Scenario: Administration when not an administrator
    Given I am registered and logged in as annika
    When I go to the administration root page
    Then I should be on the root page
    And I should not see "Administration"
