Feature: Service person updates sale person's lead

  Scenario:
    Given I am signed in as a service person
    And I have invited Benny
    And a lead exists with user: Benny, assignee: Benny, status: "Offer Requested", phone: "1234", email: "test@test.com", job_title: "asdf", salutation: "Mr"
    When I go to the lead's page
    And I press "Convert"
    And I fill in "Account Name" with "My New Account"
    And I fill in "Budget" with "1000"
    And I fill in "Title" with "A great opportunity"
    And I press "Convert Lead"
    Then I should see "Edit Account"
