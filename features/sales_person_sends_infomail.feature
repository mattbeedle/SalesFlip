Feature: Sales person sends infomail

  Scenario: without a campaign
    Given I am registered and logged in as annika
    And a infomail template exists with name: "Default", subject: "Default", body: "Default"
    And a lead: "erich" exists with user: annika, assignee: annika, email: "erich@example.com"
    And all emails have been delivered
    When I go to the lead page
    And I follow "Send Infomail"
    And I select "Default" from "Template"
    And I press "Send Infomail"
    And 1 email should be delivered with to: "erich@example.com", subject: "Default"

  Scenario: with a campaign
    Given I am registered and logged in as annika
    And a campaign: "generate_leads" exists
    And a infomail template exists with name: "Default", subject: "Default", body: "Default"
    And a infomail template exists with name: "Campaign", subject: "Campaign", body: "Campaign", campaign: generate_leads
    And a lead: "erich" exists with user: annika, assignee: annika, email: "erich@example.com", campaign: generate_leads
    And all emails have been delivered
    When I go to the lead page
    And I follow "Send Infomail"
    And I press "Send Infomail"
    And 1 email should be delivered with to: "erich@example.com", subject: "Campaign"

