Feature: Manage contacts
  In order to keep track of contacts
  A User
  wants to manage contacts

  Scenario: Filtering Contacts Assigned to Me
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And a contact: "florian" exists with user: Annika
    And a contact: "steven" exists with user: Benny
    And I am on the contacts page
    When I check "Assigned to me"
    And I press "filter"
    Then I should be on the contacts page
    And I should see "Florian"
    And I should not see "Steven"

  Scenario: Filtering Contacts by Source
    Given I am registered and logged in as annika
    And a contact: "florian" exists with user: Annika, source: "Campaign"
    And a contact: "steven" exists with user: Annika, source: "Conference"
    And I am on the contacts page
    When I select "Campaign" from "source_is"
    And I press "filter"
    Then I should be on the contacts page
    And I should see "Florian"
    And I should not see "Steven"

  Scenario: Filtering Contacts by Name
    Given I am registered and logged in as annika
    And a contact: "florian" exists with user: Annika
    And a contact: "steven" exists with user: Annika
    And I am on the contacts page
    When I fill in "name_like" with "Florian B"
    And I press "filter"
    Then I should be on the contacts page
    And I should see "Florian"
    And I should not see "Steven"

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
    
  Scenario: Updating a contact
    Given I am registered and logged in as annika
    And a contact: "florian" exists with user: annika
    And I am on the contact's edit page
    When I press "contact_submit"
    Then I should be on the contact's page
    And a new "Updated" activity should have been created for "Contact" with "first_name" "Florian" and user: "annika"
    
  Scenario: Re-assigning a contact
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And a contact: "florian" exists with user: annika
    And I am on the contact's edit page
    When I select "benjamin.pochhammer@1000jobboersen.de" from "contact_assignee_id"
    And I press "contact_submit"
    Then I should be on the contact's page
    And the contact should be assigned to Benny

  Scenario: Viewing contacts
    Given I am registered and logged in as annika
    And a contact: "florian" exists with user: annika
    And I am on the dashboard page
    When I follow "contacts"
    Then I should see "Behn, Florian"
    And I should be on the contacts page
  
  Scenario: Editing a contact from index page
    Given I am registered and logged in as annika
    And contact: "florian" exists with user: annika
    And I am on the contacts page
    When I follow the edit link for the contact
    Then I should be on the contact's edit page

  #Scenario: Deleting a contact from the index page
  #  Given I am registered and logged in as annika
  #  And a user: "benny" exists
  #  And benny belongs to the same company as annika
  #  And contact: "florian" exists with user: benny
  #  And I am on the contacts page
  #  When I click the delete button for the contact
  #  Then I should be on the contacts page
  #  And I should not see "Florian Behn" within "#main"
  #  And a new "Deleted" activity should have been created for "Contact" with "first_name" "Florian" and user: "annika"
  
  Scenario: Viewing a contact
    Given I am registered and logged in as annika
    And a contact "florian" exists with user: annika
    And I am on the dashboard page
    And I follow "contacts"
    When I follow "florian-behn"
    Then I should see "Florian Behn"
    And I should be on the contact page
    And a new "Viewed" activity should have been created for "Contact" with "first_name" "Florian"

  Scenario: Editing a account from the show page
    Given I am registered and logged in as annika
    And account: "careermee" exists with user: annika
    And I am on the account's page
    When I follow the edit link for the account
    Then I should be on the account's edit page
    
  #Scenario: Deleting a contact form the show page
  #  Given I am registered and logged in as annika
  #  And a user: "benny" exists
  #  And a contact "florian" exists with user: benny
  #  And I am on the contact's page
  #  When I click the delete button for the contact
  #  Then I should be on the contacts page
  #  And I should not see "Florian" within "#main"
  #  And a new "Deleted" activity should have been created for "Contact" with "first_name" "Florian" and user: "annika"

  Scenario: Adding an opportunity to a contact
    Given I am registered and logged in as annika
    And a contact exists with user: Annika
    And I am on the contact's page
    When I follow "Add Opportunity"
    And I fill in "Title" with "Offer number 1"
    And I fill in "Budget" with "2000"
    And I attach the file "test/support/AboutStacks.pdf" to "Attachment"
    And I press "Create Opportunity"
    Then I should be on the contact's page
    And 1 opportunities should exist with title: "Offer number 1"
    And I should see "Offer number 1"

  Scenario: Adding a task to a contact
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And a contact: "florian" exists with user: benny
    And a task exists with asset: contact, name: "Close the deal"
    And I am on the contact's page
    And I follow "add_task"
    And I follow "preset_date"
    And I fill in "task_name" with "Call to get offer details"
    And I select "As soon as possible" from "task_due_at"
    And I select "Call" from "task_category"
    When I press "task_submit"
    Then I should be on the contact's page
    And 2 tasks should have been created
    And I should see "Call to get offer details"

  Scenario: Marking a contact task as completed
    Given I am registered and logged in as annika
    And a contact exists with user: annika
    And a task exists with asset: the contact, name: "Call to get offer details", user: annika
    And I am on the contact's page
    When I check "Call to get offer details"
    And I press "task_submit"
    Then the task "Call to get offer details" should have been completed
    And I should be on the contact's page
    And I should not see "Call to get offer details" within "#main"
    And a new "Completed" activity should have been created for "Task" with "name" "Call to get offer details" and user: "annika"

  Scenario: Deleting a task
    Given I am registered and logged in as annika
    And a contact exists with user: annika
    And a task exists with asset: the contact, name: "Call to get offer details", user: annika
    And I am on the contact's page
    When I click the delete button for the task
    Then I should be on the contact's page
    And a task should not exist
    And I should not see "Call to get offer details" within "#main"

  Scenario: Adding a comment
    Given I am registered and logged in as annika
    And a contact exists with user: annika
    And I am on the contact's page
    And I fill in "comment_text" with "This is a good lead"
    When I press "comment_submit"
    Then I should be on the contact page
    And I should see "This is a good lead"
    And 1 comments should exist
    And a new "Created" activity should have been created for "Comment" with "text" "This is a good lead" and user: "annika"

  @wip
  Scenario: Adding a comment with an attachment
    Given I am registered and logged in as annika
    And a contact exists with user: annika
    And I am on the contact's page
    And I fill in "comment_text" with "Sent offer"
    And I attach the file at "test/upload-files/erich_offer.pdf" to "Attachment"
    When I press "comment_submit"
    Then I should be on the contact page
    And I should see "Sent offer"
    And I should see "erich_offer.pdf"

  Scenario: Viewing activites on the show page
    Given I am registered and logged in as annika
    And a contact exists with user: annika
    And I am on the contact's page
    And I follow the edit link for the contact
    When I select "Mr" from "contact_salutation"
    And I press "contact_submit"
    Then I should be on the contact's page
    And I should see "Updated"
    And I should see "Contact Updated by annika.fleischer"

  Scenario: Exporting Contacts as an admin
    Given I am registered and logged in as Matt
    And an contact exists with user: Matt
    And I am on the contacts page
    When I follow "Export this list as a CSV"
    Then I should be on the export contacts page
