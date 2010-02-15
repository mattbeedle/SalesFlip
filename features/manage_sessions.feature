Feature: Manage sessions
  In order to access the application
  A User
  wants to log in and out

  Scenario: Logging in
    Given I have registered
    And I am on the login page
    And I fill in the login form
    When I press "user_submit"
    Then I should be on the dashboard page
