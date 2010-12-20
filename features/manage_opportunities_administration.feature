Feature: Manage Opportunities Administration
  In order to keep track of the current business opportunities and get an understanding of our future revenue
  An Administrator
  Wants to manage opportunities administration

  Scenario: Viewing opportunities
    Given 1000JobBoersen exists
    And 1000JobBoersen has no opportunity stages
    And Matt exists with company: 1000JobBoersen, username: "Matt"
    And Prospecting stage exists with company: 1000JobBoersen
    And Negotiation stage exists with company: 1000JobBoersen
    And Closed/Won stage exists with company: 1000JobBoersen
    And I am logged in as Matt
    And an opportunity exists with user: Matt, amount: 1000, probability: 75, margin: 35, stage: Prospecting stage
    And opportunity: "closed_today" exists with user: Matt, amount: 1250, margin: 40
    And I am on the root page
    When I follow "Administration"
    And I follow "Opportunities"
    Then I should see "prospecting"
    And I should see "1"
    And I should see "negotiation"
    And I should see "0"
    And I should see "$1,250.00"
