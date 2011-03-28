Feature: Sales person sets their signature

  Scenario:
    Given a user: "annika" exists
    And I am signed in as a sales person
    When I go to the profile page
    And I fill in "Signature" with "Mit freundlichen Gruessen, Annika"
    And I press "Save"
    Then I should be on the profile page
    And the "Signature" field should contain "Mit freundlichen Gruessen, Annika"
