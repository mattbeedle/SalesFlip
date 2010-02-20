Feature: Manage contacts
  In order to keep track of contacts
  A User
  wants to manage contacts

  Scenario: Adding a contact when the account exists
    Given I am registered and logged in as annika
    And an account: "careermee" exists
    And I am on the contacts page
    And I follow "new"
    And I select "CareerMee" from "contact_account_id"
    And I fill in "contact_first_name" with "Florian"
    And I fill in "contact_last_name" with "Behn"
    When I press "contact_submit"
    Then I should be on the contact page
    And I should see "Florian Behn"
    And account: "careermee" should have a contact with first_name: "Florian"
    And a new "Created" activity should have been created for "Contact" with "first_name" "Florian"

  Scenario: Adding a contact when the account does not exist
    Given I am registered and logged in as annika
    And I am on the new contact page
    And I follow "new_account"
    And I fill in "account_name" with "World Dating"
    And I press "account_submit"
    And I fill in "contact_first_name" with "Florian"
    And I fill in "contact_last_name" with "Behn"
    And I select "World Dating" from "contact_account_id"
    When I press "contact_submit"
    Then I should be on the contact page
    And I should see "Florian Behn"
    And I should see "World Dating"
    And an account should exist with name: "World Dating"
    And a contact should exist with first_name: "Florian", last_name: "Behn"

  Scenario: Viewing contacts
    Given I am registered and logged in as annika
    And a contact: "florian" exists with user: annika
    And I am on the dashboard page
    When I follow "contacts"
    Then I should see "Florian Behn"
    And I should be on the contacts page

  Scenario: Viewing a contact
    Given I am registered and logged in as annika
    And a contact "florian" exists with user: annika
    And I am on the dashboard page
    And I follow "contacts"
    When I follow "florian-behn"
    Then I should see "Florian Behn"
    And I should be on the contact page
    And a new "Viewed" activity should have been created for "Contact" with "first_name" "Florian"

  Scenario: Deleting a contact
    Given I am registered and logged in as annika
    And a contact "florian" exists with user: annika
    And I am on the contact's page
    When I press "delete"
    Then I should be on the contacts page
    And I should not see "Florian"

  Scenario: Deleting from the index page
    Given I am registered and logged in as annika
    And a contact "florian" exists with user: annika
    And I am on the contacts page
    When I press "delete_florian-behn"
    Then I should be on the contacts page
    And I should not see "Florian"

  Scenario: Private contact (in)visibility on the contacts page
    Given I am registered and logged in as annika
    And a user: "benny" exists
    And a contact: "florian" exists with user: benny, permission: "Public"
    And a contact exists with user: benny, first_name: "Joe", permission: "Private"
    When I go to the contacts page
    Then I should see "Florian"
    And I should not see "Joe"

  Scenario: Shared lead visibility on leads page
    Given I am registered and logged in as benny
    And a contact: "florian" exists with user: benny, permission: "Private"
    And user: "annika" exists
    And I go to the new contact page
    And I fill in "contact_first_name" with "Steven"
    And I fill in "contact_last_name" with "Garcia"
    And I select "Shared" from "contact_permission"
    And I select "annika.fleischer@1000jobboersen.de" from "contact_permitted_user_ids"
    And I press "contact_submit"
    And I logout
    And I login as annika
    When I go to the contacts page
    Then I should see "Steven"
    And I should not see "Florian"

  Scenario: Viewing a shared contact details
    Given I am registered and logged in as annika
    And a user: "benny" exists
    And a contact: "florian" exists with user: benny
    And florian is shared with annika
    And I am on the contacts page
    When I follow "florian-behn"
    Then I should be on the contact's page
    And I should see "Florian"
