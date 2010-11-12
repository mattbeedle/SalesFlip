Feature: Recycle Bin
  In order to recover deleted items
  An Administrator
  wants a recycle bin

  Scenario: Recycle bin navigation
    Given Matt exists
    And I am logged in as Matt
    And a lead: "erich" exists with user: Matt
    And erich has been deleted
    When I am on the dashboard page
    Then I should see "(1)"
    
  Scenario: Recycle bin navigation as a normal user
    Given I am registered and logged in as annika
    And I am on the dashboard page
    Then I should not see "Recycle Bin"
    
  Scenario: Recycle bin page as a normal user
    Given I am registered and logged in as annika
    When I go to the deleted items page
    Then I should be on the root page
    And I should see "Access denied"

  Scenario: Private item (in)visibility
    Given Matt exists
    And I am logged in as Matt
    And a user: "benny" exists
    And a lead: "erich" exists with user: benny, permission: "Private"
    And erich has been deleted
    When I go to the recycle bin page
    Then I should not see "Erich"
    And I should not see "Recycle Bin (1)"

  Scenario: Restoring a lead
    Given Matt exists
    And I am logged in as Matt
    And a lead: "erich" exists with user: Matt
    And erich has been deleted
    And I go to the recycle bin page
    When I press "restore_erich-feldmeier"
    Then I should be on the recycle bin page
    And a lead should exist with deleted_at: nil
    And I should see "Recycle Bin"
    And I should not see "Recycle Bin (1)"

  # Scenario: Permanently deleting a lead
  #   Given I am registered and logged in as annika
  #   And a lead: "erich" exists with user: annika
  #   And erich has been deleted
  #   When I go to the recycle bin page
  #   And I click the delete button for the lead
  #   Then I should be on the recycle bin page
  #   And a lead should not exist with first_name: "Erich"
  #   And I should see "Recycle Bin"
  #   And I should not see "Recycle Bin (1)"
  # 
  # Scenario: Deleting a lead with comments
  #  Given I am registered and logged in as annika
  #  And a user: "benny" exists
  #  And benny belongs to the same company as annika
  #  And a lead "erich" exists with user: benny
  #  And a comment exists with user: benny, commentable: lead, text: "Delete me too!"
  #  And I am on the leads page
  #  When I click the delete button for the lead
  #  And a new "Deleted" activity should have been created for "Lead" with "first_name" "Erich" and user: "annika"
  #  And I follow "recycle_bin"
  #  And I click the delete button for the lead
  #  Then I should not see "Erich" within "#main"

  Scenario: Restoring a contact
    Given Matt exists
    And I am logged in as Matt
    And a contact: "florian" exists with user: Matt
    And florian has been deleted
    And I go to the recycle bin page
    When I press "restore_florian-behn"
    Then I should be on the recycle bin page
    And a contact should exist with deleted_at: nil

  Scenario: Permanently deleting a contact
    Given Matt exists
    And I am logged in as Matt
    And a contact: "florian" exists with user: Matt
    And florian has been deleted
    When I go to the recycle bin page
    And I click the delete button for the contact
    Then I should be on the recycle bin page
    And a contact should not exist with first_name: "Florian"

  # Scenario: Deleting a contact with comments
  #   Given I am registered and logged in as annika
  #   And a user: "benny" exists
  #   And benny belongs to the same company as annika
  #   And a contact "florian" exists with user: benny
  #   And a comment exists with user: benny, commentable: contact, text: "Delete me too!"
  #   And I am on the contacts page
  #   When I click the delete button for the contact
  #   Then I should be on the contacts page
  #   When I follow "recycle_bin"
  #   And I click the delete button for the contact
  #   Then I should not see "Florian" within "#main"
  #   When I follow "Dashboard"
  #   Then I should be on the dashboard page
  #   And I should not see "Delete me too!"
  
    
  Scenario: Restoring an account
    Given Matt exists
    And I am logged in as Matt
    And an account: "careermee" exists with user: Matt
    And careermee has been deleted
    And I go to the recycle bin page
    When I press "restore_careermee"
    Then I should be on the recycle bin page
    And an account should exist with deleted_at: nil

  Scenario: Permanently deleting an account
    Given Matt exists
    And I am logged in as Matt
    And an account: "careermee" exists with user: Matt
    And careermee has been deleted
    When I go to the recycle bin page
    And I click the delete button for the account
    Then I should be on the recycle bin page
    And an account should not exist with name: "CareerMee"
    
  #Scenario: Permanently deleting an account with comments
  # Given I am registered and logged in as annika
  # And a user: "benny" exists
  # And benny belongs to the same company as annika
  # And account: "careermee" exists with user: benny
  # And a comment exists with user: benny, commentable: account, text: "Delete me too!"
  # And I am on the accounts page
  # When I click the delete button for the account
  # Then I should be on the accounts page
  # And I should not see "CareerMee" within "#main"
  # And a new "Deleted" activity should have been created for "Account" with "name" "CareerMee" and user: "annika"
  # When I follow "recycle_bin"
  # And I click the delete button for the account
  # Then I should not see "careermee"
  # When I follow "Dashboard"
  # Then I should be on the dashboard page
  # And I should not see "Delete me too!"
