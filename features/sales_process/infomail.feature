Feature: Infomail workflow

  @javascript
  Scenario: Customer requests infomail
    Given I am signed in as a sales person
    And my email signature is "Cheers, Sales Person"
    And an infomail template exists with name: "Default", subject: "1000Jobboersen.de", body: "Learn More"
    And there is a new lead assigned to me with salutation: "Mr", title: "Dr.", last_name: "Beedle"
    And I am on the lead's page
    And I have called the customer

    When I say the customer requested infomail
    And I press "Send Infomail"

    And I schedule an infomail followup task
    Then the lead should have the status "Infomail Sent"
    And it should have an infomail followup task
    And 1 email should be delivered with subject: "1000Jobboersen.de", from: "service@salesflip.com"
    And the email should contain "Dear Mr. Dr. Beedle"
    And the email should contain "Learn More"
    And the email should contain "Cheers, Sales Person"

  @javascript
  Scenario: no salutation
    Given I am signed in as a sales person
    And my email signature is "Cheers, Sales Person"
    And an infomail template: "default" exists
    And there is a new lead assigned to me
    And I am on the lead's page
    And I have called the customer

    When I say the customer requested infomail
    And I select "Mrs" from "Salutation"
    And I press "Send Infomail"

    Then the lead should have the status "Infomail Sent"
    And 1 email should be delivered
    And the email should contain t(dear_madam)

  @javascript
  Scenario: no email
    Given I am signed in as a sales person
    And my email signature is "Cheers, Sales Person"
    And an infomail template: "default" exists
    And there is a new lead assigned to me with email: nil
    And I am on the lead's page
    And I have called the customer

    When I say the customer requested infomail
    And I fill in "Email" with "user@test.test"
    And I press "Send Infomail"

    Then the lead should have the status "Infomail Sent"
    And 1 email should be delivered to "user@test.test"

  @javascript
  Scenario: no title
    Given I am signed in as a sales person
    And my email signature is "Cheers, Sales Person"
    And an infomail template: "default" exists
    And there is a new lead assigned to me with last_name: "unknown"
    And I am on the lead's page
    And I have called the customer

    When I say the customer requested infomail
    And I select "Dr." from "Title"
    And I press "Send Infomail"

    Then the lead should have the status "Infomail Sent"
    And 1 email should be delivered
    And the email should contain "Dr."

  @javascript
  Scenario: no last name
    Given I am signed in as a sales person
    And my email signature is "Cheers, Sales Person"
    And an infomail template: "default" exists
    And there is a new lead assigned to me with last_name: "unknown"
    And I am on the lead's page
    And I have called the customer

    When I say the customer requested infomail
    And I fill in "Last Name" with "Beedle"
    And I press "Send Infomail"

    Then the lead should have the status "Infomail Sent"
    And 1 email should be delivered
    And the email should contain "Beedle"

  @javascript
  Scenario: no signature
    Given I am signed in as a sales person
    And an infomail template: "default" exists
    And there is a new lead assigned to me
    And I am on the lead's page
    And I have called the customer

    When I say the customer requested infomail
    And I fill in "Signature" with "Cheers, Sales Person"
    And I press "Send Infomail"

    Then the lead should have the status "Infomail Sent"
    And 1 email should be delivered
    And the email should contain "Cheers, Sales Person"
