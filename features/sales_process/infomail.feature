Feature: Infomail workflow

  Scenario: manually sending infomail
    Given I am signed in as a sales person
    And I have a lead with the status "Infomail Requested"
    When I go to the leads page
    And I follow "Infomail Requested"
    Then I should see the lead

    When go to the lead's page
    And I follow "Infomail Sent?"
    Then I should be on the lead's page
    And the lead's status should be "Infomail Sent"
