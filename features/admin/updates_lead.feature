Feature: Admin updates lead

  Scenario:
    Given I am registered and logged in as Matt
    And Matt has invited Annika
    And a lead exists with assignee: Annika
    When I go to the lead's edit page
    And I fill in "Last Name" with "Spiedelmeier"
    And I press "Update Lead"
    Then I should be on the lead's page
    And I should see "Spiedelmeier"
