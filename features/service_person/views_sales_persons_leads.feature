Feature: Service person views sale person's leads

  Scenario:
    Given I am signed in as a service person
    And I have invited Benny
    And a lead exists with user: Benny, assignee: Benny, status: "Offer Requested", first_name: "John", last_name: "Doe"
    When I go to the leads page
    Then I should see "Offer Requested" within ".tabs .active"
    And I should see "John Doe"
