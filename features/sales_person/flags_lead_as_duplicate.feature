Feature: Sales person flags lead as duplicate

  Scenario:
    Given a user: "annika" exists
    And a lead exists with assignee: annika
    And I am signed in as a sales person
    When I go to the lead's page
    And I follow "mark this as a duplicate"
    Then I should be on the lead's page
    And I should see "marked as a duplicate"
