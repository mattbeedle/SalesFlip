Feature: User searches site

  Scenario: fixing a search with no terms
    Given I am registered and logged in as annika
    And I am on the home page
    And I uncheck "Leads"
    When I press "Search"
    Then I should see "can't be blank"
    And the "Leads" checkbox should not be checked

    When I fill in "Terms" with "Monster"
    And I press "Search"
    Then I should see /Search Results for "Monster"/

  Scenario: searches twice and hits 'go back'
    Given I am registered and logged in as annika
    And I am on the home page
    And I press "Search"
    And I press "Search"
    And I follow "Go Back"
    Then I should be on the new search page
