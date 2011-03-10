Feature: Sales person views another user's lead

  Scenario:
    Given a user: "annika" exists
    And a lead exists with assignee: annika, phone: "123-456-7890"
    And I am signed in as a sales person
    When I go to the lead's page
    Then I should see "123-456-7890"
    But I should not see "Already contacted?"
