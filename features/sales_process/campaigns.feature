Feature: Campaign workflow

  Scenario: only sees campaigns for assigned leads
    Given I am signed in as a sales person
    And a campaign exists with name: "Email Blast"
    And a campaign: "generate_leads" exists
    And a lead exists with first_name: "Jane", user: me, assignee: me, status: "New", campaign: generate_leads
    When I go to the leads page
    Then I should see "Generate 100 leads this month"
    But I should not see "Email Blast"

  Scenario Outline: only see self-generated leads
    Given I am signed in as a sales person
    And a lead exists with first_name: "John", user: me, assignee: me, status: "New", source: "Cold Call"
    And a lead exists with first_name: "Jane", user: me, assignee: me, status: "New", source: "Self-Generated"
    And my locale is "<locale>"
    When I go to the leads page
    Then I should see "John"
    And I should see "Jane"
    When I follow t(self_generated)
    Then I should see "Jane"
    But I should not see "John"
    When I follow "x" within ".filters .active"
    Then I should see "John"
    And I should see "Jane"

    Examples:
      | locale |
      | en     |
      | de     |

  Scenario: only see leads from a campaign
    Given I am signed in as a sales person
    And a campaign: "generate_leads" exists
    And a lead exists with first_name: "John", user: me, assignee: me, status: "New"
    And a lead exists with first_name: "Jane", user: me, assignee: me, status: "New", campaign: generate_leads
    When I go to the leads page
    Then I should see "John"
    And I should see "Jane"

    When I follow "Generate 100 leads this month"
    Then I should see "Jane"
    But I should not see "John"

    When I follow "x" within ".filters .active"
    Then I should see "John"
    And I should see "Jane"

  Scenario: filters are sticky
    Given I am signed in as a sales person
    And a campaign: "generate_leads" exists
    And a lead exists with first_name: "Jane", user: me, assignee: me, status: "Offer Requested", campaign: generate_leads
    And a lead exists with first_name: "John", user: me, assignee: me, status: "Offer Requested"
    When I go to the leads page
    And I follow "Generate 100 leads this month"
    And I follow "Offer Requested"
    Then I should see "Jane"
    But I should not see "John"

    When I go to the tasks page
    And I go to the leads page
    And I follow "Offer Requested"
    Then I should see "Jane"
    But I should not see "John"

    When I follow "x" within ".filters .active"
    Then I should see "Jane"
    And I should see "John"
