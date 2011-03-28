Feature: Infomail workflow

  @javascript
  Scenario: Customer requests infomail
    Given I am signed in as a sales person
    And my email signature is "Cheers, Sales Person"
    And an infomail template exists with name: "Default", subject: "1000Jobboersen.de", body: "Learn More"
    And there is a new lead assigned to me with salutation: "Mr"
    And I am on the lead's page
    And I have called the customer

    When I say the customer requested infomail
    And I press "Send Infomail"

    And I schedule an infomail followup task
    Then the lead should have the status "Infomail Sent"
    And it should have an infomail followup task
    And 1 email should be delivered with subject: "1000Jobboersen.de", from: "service@salesflip.com"
    And the email should contain t(dear_sir)
    And the email should contain "Learn More"
    And the email should contain "Cheers, Sales Person"
