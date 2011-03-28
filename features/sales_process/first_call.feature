Feature: First call workflow

  Scenario: User gets a new lead
    Given I am signed in as a sales person
    And there is a new unassigned lead
    When I go to the leads page
    Then I should see no leads

    When I ask for my next lead
    Then the lead should be assigned to me
    And I should be on the lead's page

  Scenario: User with new assigned leads can't get another lead
    Given I am signed in as a sales person
    And there is a new lead assigned to me
    When I go to the leads page
    And I ask for my next lead
    Then I should be on the lead's page

    @javascript
  Scenario: Customer wants to be called back
    Given I am signed in as a sales person
    And there is a new lead assigned to me
    And I am on the lead's page
    And I have called the customer

    When I say the customer wants to be called back
    And I reschedule the call
    Then the lead should have the status "Contacted"
    And it should have a task for the rescheduled call

    @javascript
  Scenario: Customer doesn't want to be called back
    Given I am signed in as a sales person
    And there is a new lead assigned to me
    And I am on the lead's page
    And I have called the customer

    When I say the customer doesn't want to be called back
    Then the lead should have the status "Rejected"

    @javascript
  Scenario: Customer requests an offer
    Given I am signed in as a sales person
    And there is a new lead assigned to me
    And I am on the lead's page
    And I have called the customer

    When I say the customer requested an offer
    When I schedule an email task to send the offer
    Then the lead should have the status "Offer Requested"
    And it should have an email task to send the offer
