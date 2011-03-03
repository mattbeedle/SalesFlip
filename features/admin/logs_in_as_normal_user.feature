Feature: Admin logs in as normal user

  Scenario:
    Given I am registered and logged in as Matt
    And Matt has invited Annika
    When I go to the users page
    And I follow "Annika"
    And I follow "Log in as Annika"
    Then I should see "Welcome Annika"
    And I should see "You are logged in as Annika"

    When I go to the administration leads page
    Then I should see "Access denied"

    When I go to the users page
    And I follow "Annika"
    Then I should not see "Log in as Annika"

    When I follow "Return to your account"
    Then I should see "Welcome matt"
