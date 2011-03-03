Feature: Manage leads
  In order to keep track of leads
  A user
  wants manage leads

  Scenario: Adding a comment after first attempt was invalid
    Given I am registered and logged in as Matt
    And a lead exists with user: Matt
    And I am on the lead's page
    When I press "Save Comment"
    And I fill in "Add Comment" with "some text"
    And I press "Save Comment"
    Then I should be on the lead's page
    And the comment should have been created for the lead

  Scenario: Importing leads from a CSV
    Given I am registered and logged in as Matt
    And Annika exists with email: "annika.fleischer@1000jobboersen.de"
    And Annika belongs to the same company as Matt
    And all delayed jobs have finished
    And all emails have been delivered
    And I am on the leads page
    When follow "Import from CSV"
    And I attach the file "test/support/leads.csv" to "lead_import_file"
    And I select "annika.fleischer@1000jobboersen.de" from "Assignee"
    And I fill in "Deliminator" with ";"
    And I press "Upload"
    And I press "Confirm"
    And all delayed jobs have finished
    Then 3 leads should exist
    And an import summary email should have been sent
    And I should see "Your leads are being imported now. You will receive a summary email when the import has finished"

  Scenario: Re-assigning a lead
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And a lead: "erich" exists with user: Annika, assignee: Annika
    And all emails have been delivered
    And I am on the lead's page
    When I follow "Edit"
    And I select "benjamin.pochhammer@1000jobboersen.de" from "Assignee"
    And I press "Update Lead"
    And all delayed jobs have finished
    Then I should be on the lead's page
    And 1 emails should be delivered to "benjamin.pochhammer@1000jobboersen.de"

  Scenario: Creating a lead
    Given I am registered and logged in as annika
    And I am on the leads page
    And all emails have been delivered
    And I follow "new"
    And I fill in "lead_first_name" with "Erich"
    And I fill in "lead_last_name" with "Feldmeier"
    When I press "lead_submit"
    And the lead is stored
    Then I should be on the lead's page
    And I should see "Erich Feldmeier"
    And a created activity should exist for lead with first_name "Erich"
    And 0 emails should be delivered

  Scenario: Creating a lead as a freelancer
    Given Carsten Werner exists
    And Carsten Werner is confirmed
    And I am logged in as Carsten Werner
    And I am on the leads page
    And all emails have been delivered
    And I follow "new"
    And I fill in "lead_first_name" with "Erich"
    And I fill in "lead_last_name" with "Feldmeier"
    When I press "lead_submit"
    And the lead is stored
    Then I should be on the lead's page
    And 1 leads should exist with first_name: "Erich", last_name: "Feldmeier"
    And I should see "Erich Feldmeier"
    And a created activity should exist for lead with first_name "Erich"
    And 0 emails should be delivered

  Scenario: Trying to assign a new private lead
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And I am on the new lead page
    When I fill in "Last Name" with "A test"
    And I select "benjamin.pochhammer@1000jobboersen.de" from "lead_assignee_id"
    And I select "Private" from "Permission"
    And I press "Create Lead"
    Then 0 leads should exist
    And I should see "Cannot assign a private lead to another user, please change the permissions first"

  Scenario: Trying to assign a new shared lead to a user it is not shared with
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And I am on the new lead page
    When I fill in "Last Name" with "test"
    And I select "Shared" from "Permission"
    And I select "annika.fleischer@1000jobboersen.de" from "lead_permitted_user_ids"
    And I select "benjamin.pochhammer@1000jobboersen.de" from "Assignee"
    And I press "Create Lead"
    Then 0 leads should exist
    And I should see "Cannot assign a shared lead to a user it is not shared with. Please change the permissions first"

  Scenario: Creating a lead with a campaign
    Given I am registered and logged in as annika
    And a campaign exists with name: "Generate 100 leads this month", start_date: "1/12/2010", end_date: "31/12/2010"
    When I am on the new lead page
    Then I should see "Campaign" within ".simple_form"
    When I fill in "First Name" with "Erich"
    And I fill in "Last Name" with "Feldmeier"
    And I select "Generate 100 leads this month" from "Campaign"
    And I press "lead_submit"
    Then I should see "Generate 100 leads this month"

  @wip
  Scenario: Creating a lead via XML
    Given I am registered and logged in as annika
    When I POST attributes for lead: "erich" to the leads page
    Then 1 leads should exist with assignee_id: nil

  Scenario: Adding a comment
    Given I am registered and logged in as annika
    And a lead exists with user: annika
    And I am on the lead's page
    And I fill in "comment_text" with "This is a good lead"
    When I press "comment_submit"
    Then I should be on the lead page
    And I should see "This is a good lead"
    And 1 comments should exist

  Scenario: Adding an comment with an attachment
    Given I am registered and logged in as annika
    And a lead exists with user: annika
    And I am on the lead's page
    And I fill in "comment_text" with "Sent offer"
    And I attach the file "test/upload-files/erich_offer.pdf" to "Attachment"
    When I press "comment_submit"
    Then I should be on the lead page
    And I should see "Sent offer"
    And I should see "erich_offer.pdf"

  Scenario: Editing a lead
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: annika, assignee: annika
    And I am on the lead's page
    And I follow the edit link for the lead
    And I fill in "lead_phone" with "999"
    When I press "lead_submit"
    Then a lead should exist with phone: "999"
    And an updated activity should exist for lead with first_name "Erich"

  #Scenario: Deleting a lead from the index page
  #  Given I am registered and logged in as annika
  #  And Annika has invited Benny
  #  And benny belongs to the same company as annika
  #  And a lead "erich" exists with user: benny
  #  And I am on the leads page
  #  When I click the delete button for the lead
  #  Then I should be on the leads page
  #  And lead "erich" should have been deleted
  #  And a new "Deleted" activity should have been created for "Lead" with "first_name" "Erich" and user: "annika"

  Scenario: Leads index when freelance user
    Given a user: "annika" exists
    And I have accepted an invitation from annika
    And a lead: "erich" exists with user: annika
    And a lead: "markus" exists with user: user, assignee: user
    When I am on the leads page
    And I follow "All"
    Then I should not see "Erich"
    And I should see "Markus"

  Scenario: Filtering new leads (default)
    Given I am registered and logged in as annika
    And a lead exists with user: annika, status: "New", first_name: "Erich", assignee: annika
    And a lead exists with user: annika, status: "Rejected", first_name: "Markus", assignee: annika
    And I go to the leads page
    Then I should see "Erich"
    And I should not see "Markus"

  Scenario: Filtering new leads
    Given I am registered and logged in as annika
    And a lead exists with user: annika, status: "New", first_name: "Erich", assignee: annika
    And a lead exists with user: annika, status: "Rejected", first_name: "Markus", assignee: annika
    And I go to the leads page
    And I follow "New"
    Then I should see "Erich"
    And I should not see "Markus"

  Scenario: Deleted leads
    Given I am registered and logged in as annika
    And a lead: "kerstin" exists with user: annika
    When I am on the leads page
    Then I should not see "Kerstin"

  Scenario: Viewing a lead
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: annika, source: "Imported", assignee: annika
    And I am on the dashboard page
    And I follow "Leads"
    When I follow "erich-feldmeier"
    Then I should be on the lead page
    And I should see "Erich"
    And a view activity should have been created for lead with first_name "Erich"
    And I should not see "delete" within "#content"

  Scenario: Editing a account from the show page
    Given I am registered and logged in as annika
    And account: "careermee" exists with user: annika
    And I am on the account's page
    When I follow the edit link for the account
    Then I should be on the account's edit page

  #Scenario: Deleting a lead from the show page
  #  Given I am registered and logged in as annika
  #  And Annika has invited Benny
  #  And a lead "erich" exists with user: benny
  #  And I am on the lead's page
  #  When I click the delete button for the lead
  #  Then I should be on the leads page
  #  And I should not see "Erich" within "#main"
  #  And a new "Deleted" activity should have been created for "Lead" with "first_name" "Erich" and user: "annika"

  Scenario: Adding a task to a lead
    Given I am registered and logged in as annika
    And a lead exists with user: annika
    And a task exists with asset: lead, name: "Close the deal"
    And I am on the lead's page
    And all emails have been delivered
    And I follow "add_task"
    And I follow "preset_date"
    And I fill in "task_name" with "Call to get offer details"
    And I select "As soon as possible" from "task_due_at"
    And I select "Call" from "task_category"
    When I press "task_submit"
    Then I should be on the lead's page
    And 2 tasks should have been created
    And I should see "Call to get offer details"
    And I should see "Close the deal"
    And 0 emails should be delivered

  Scenario: Adding a task to an unassigned lead
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And a lead exists with user: Benny, assignee_id: nil
    And I am on the lead's page
    And all emails have been delivered
    And I follow "add_task"
    And I follow "preset_date"
    And I fill in "task_name" with "Call to get offer details"
    And I select "As soon as possible" from "task_due_at"
    And I select "Call" from "task_category"
    When I press "task_submit"
    Then I should be on the lead's page
    And a task should have been created
    And I should see "Call to get offer details"
    And 0 emails should be delivered
    And the lead should be assigned to Annika

  Scenario: Marking a lead as completed
    Given I am registered and logged in as annika
    And a lead exists with user: annika
    And a task exists with asset: the lead, name: "Call to get offer details", user: annika
    And I am on the lead's page
    When I check "Call to get offer details"
    And I press "task_submit"
    Then the task "Call to get offer details" should have been completed
    And I should be on the lead's page
    And I should not see "Call to get offer details" within "#main"

  Scenario: Deleting a task
    Given I am registered and logged in as annika
    And a lead exists with user: annika
    And a task exists with asset: the lead, name: "Call to get offer details", user: annika
    And I am on the lead's page
    When I click the delete button for the task
    Then I should be on the lead's page
    And a task should not exist
    And I should not see "Call to get offer details" within "#main"

  Scenario: Rejecting a lead
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And a lead: "erich" exists with user: benny, assignee: Annika, status: "Contacted"
    And I am on the lead's page
    When I press "Reject"
    Then I should be on the leads page
    And lead "erich" should exist with status: "Rejected"
    And a new "Rejected" activity should have been created for "Lead" with "first_name" "Erich" and user: "annika"

  Scenario: Converting a lead to a new account
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And a lead: "erich" exists with user: benny, assignee: Annika, status: "Contacted"
    And I am on the lead's page
    When I follow "Convert"
    And I fill in "account_name" with "World Dating"
    And I press "convert"
    Then I should be on the account page
    And I should see "World Dating"
    And I should see "Erich"
    And 1 accounts should exist with name: "World Dating", account_type: "Prospect"
    And a contact should exist with first_name: "Erich"
    And a lead should exist with first_name: "Erich", status: "Converted"
    And a new "Created" activity should have been created for "Contact" with "first_name" "Erich" and user: "annika"
    And a new "Converted" activity should have been created for "Lead" with "first_name" "Erich" and user: "annika"
    And a new "Created" activity should have been created for "Account" with "name" "World Dating" and user: "annika"

  Scenario: Converting a lead to a new account and with an opportunity
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And a lead: "erich" exists with user: benny, assignee: Annika, status: "Contacted"
    And I am on the lead's page
    When I follow "Convert"
    And I fill in "account_name" with "World Dating"
    And I fill in "opportunity_title" with "A great opportunity"
    And I attach the file "test/support/AboutStacks.pdf" to "Attachment"
    And I press "convert"
    Then I should be on the account page
    And 1 opportunities should exist with title: "A great opportunity"
    And the newly created contact should have an opportunity

  Scenario: Converting a lead to a new account, but entering an invalid opportunity
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: Annika, assignee: Annika, status: "Contacted"
    And I am on the lead's page
    When I follow "Convert"
    And I fill in "account_name" with "World Dating"
    And I fill in "opportunity_title" with "A great opportunity"
    And I fill in "opportunity_amount" with "asdfdsafs"
    And I press "convert"
    Then I should be on the lead's promote page
    And 0 accounts should exist
    And 0 contacts should exist
    And 0 opportunities should exist

  Scenario: Converting a lead to an existing account
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: annika, assignee: Annika, status: "Contacted"
    And a account: "careermee" exists with user: annika
    And I am on the lead's page
    When I follow "Convert"
    And I select "CareerMee" from "account_id"
    And I press "convert"
    Then I should be on the account page
    And I should see "CareerMee"
    And I should see "Erich"
    And 1 accounts should exist
    And a new "Converted" activity should have been created for "Lead" with "first_name" "Erich" and user: "annika"

  Scenario: Converting a lead to an existing contact
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: annika, email: "erich.feldmeier@gmail.com", assignee: Annika, status: "Contacted"
    And account: "careermee" exists with user: annika
    And contact: "florian" exists with email: "erich.feldmeier@gmail.com", account: careermee
    And I am on the lead's page
    When I follow "Convert"
    And I press "convert"
    Then I should be on the account page
    And I should see "CareerMee"
    And 1 contacts should exist

  Scenario: Converting a lead to an existing contact that has no account
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: annika, email: "erich.feldmeier@gmail.com", assignee: Annika, status: "Contacted"
    And contact: "florian" exists with email: "erich.feldmeier@gmail.com", account: nil, user: annika
    And I am on the lead's page
    When I follow "Convert"
    And I press "convert"
    Then I should be on the contact's page
    And 1 contacts should exist

  Scenario: Converting a lead with a blank email when a contact already exists with a blank email
    Given I am registered and logged in as annika
    And a lead exists with user: annika, email: "", assignee: Annika, status: "Contacted"
    And account: "careermee" exists with user: annika
    And contact: "florian" exists with email: "", account: careermee
    And I am on the lead's page
    When I follow "Convert"
    Then I should be on the lead's convert page
    And I should not see "already exists. Press convert to add this lead to that contact"
    And I should see "Account Name"

  Scenario: Convert page when converting to an existing account
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: annika, email: "erich.feldmeier@gmail.com", assignee: Annika, status: "Contacted"
    And account: "careermee" exists with user: annika
    And contact: "florian" exists with email: "erich.feldmeier@gmail.com", account: careermee
    And I am on the lead's page
    When I follow "Convert"
    Then I should not see "Account Name"
    And I should see "convert"

  Scenario: Trying to convert a lead without entering an account name
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: annika, assignee: Annika, status: "Contacted"
    And I am on the lead's page
    When I follow "Convert"
    And I press "convert"
    Then I should be on the lead's promote page
    And I should see "Account Name"
    And I should see "Attachment"

  Scenario: Viewing a converted lead
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: annika, email: "erich.feldmeier@gmail.com", assignee: Annika, status: "Contacted"
    And account: "careermee" exists with user: annika
    And contact: "florian" exists with email: "erich.feldmeier@gmail.com", account: careermee
    And I am on the lead's page
    When I follow "Convert"
    And I press "Convert Lead"
    And I go to the lead's page
    Then I should see "This lead was converted by annika.fleischer"
    And I should see "Comments are closed"

  Scenario: Actions for a converted lead
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: annika, status: "Converted"
    And an activity exists with action: "Converted", user: annika, subject: lead
    When I am on the lead's page
    Then I should not see "Convert" within "a"
    And I should not see "Reject" within "a"

  Scenario: Actions for a rejected lead
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: annika, status: "Rejected"
    When I am on the lead's page
    Then I should not see "Convert"
    And I should not see "Reject" within "a"

  Scenario: Viewing activites on the show page
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: Annika, assignee: Annika
    And I am on the lead's page
    And I follow the edit link for the lead
    Then I should be on the lead's edit page
    When I select "Mr" from "lead_salutation"
    And I press "lead_submit"
    Then I should be on the lead's page
    And I should see "Updated"
    And I should see "Lead Updated by annika.fleischer"

  Scenario: Exporting Leads as a normal user
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: Annika
    When I am on the leads page
    Then I should not see "Export this list as a CSV"

  Scenario: Leads index with format csv as a normal user
    Given I am registered and logged in as annika
    And a lead: "erich" exists with user: Annika
    When I go to the leads csv page
    Then I should be on the root page

  Scenario: Exporting Leads as an admin
    Given I am registered and logged in as Matt
    And a lead: "erich" exists with user: Matt
    And I am on the leads page
    When I follow "Export this list as a CSV"
    Then I should be on the export leads page
