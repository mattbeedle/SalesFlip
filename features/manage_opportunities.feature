Feature: Manage Opportunities
  In order to keep track of the different business opportunities they have
  A user
  Wants to manage their opportunities

  Scenario: Creating an opportunity
    Given I am registered and logged in as annika
    And a contact: "florian" exists with user: Annika
    And I am on the opportunities page
    When I follow "new"
    And I fill in "Title" with "An opportunity"
    And I select "prospecting" from "Stage"
    And I fill in "Amount" with "1000"
    And I fill in "Discount" with "11"
    And I fill in "Budget" with "2000"
    And I attach the file "test/support/AboutStacks.pdf" to "Attachment"
    And I select "Florian Behn" from "Contact"
    And I press "Create Opportunity"
    Then I should be on the opportunities page
    And 1 opportunities should exist with title: "An opportunity", amount: 1000, discount: 11
    And Annika should have 1 opportunities
    And Annika should have 1 assigned opportunities
    And I should see "An opportunity"
    And I should see "11"
    # FIXME: attachments not working in features
    # And I should see "aboutstacks.pdf"
    And I should see "Prospecting"

  Scenario: Editing an opportunity
    Given I am registered and logged in as annika
    And a contact: "florian" exists with user: Annika
    And an opportunity exists with title: "great opportunity", user: Annika, assignee: Annika
    And I am on the opportunities page
    When I follow "Opportunities"
    And I follow "Edit"
    And fill in "Title" with "changed opportunity"
    And I select "Florian Behn" from "Contact"
    And I press "Update Opportunity"
    Then I should be on the opportunities page
    And I should see "changed opportunity"
    And I should not see "great opportunity"

  Scenario: Editing an opportunity when it is not assigned to you
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And an opportunity exists with title: "great opportunity", user: Benny, assignee: Benny
    When I follow "Opportunities"
    Then I should not see "Edit"

  Scenario: Creating an opportunity with missing attributes
    Given I am registered and logged in as annika
    And I am on the opportunities page
    When I follow "new"
    And I press "Create Opportunity"
    Then I should be on the opportunities page
    And 0 opportunities should exist

  Scenario: Adding a comment
    Given I am registered and logged in as annika
    And an opportunity exists with user: annika
    And I am on the opportunity's page
    And I fill in "comment_text" with "This is a good opportunity"
    When I press "comment_submit"
    Then I should be on the opportunity's page
    And I should see "This is a good opportunity"
    And 1 comments should exist

  Scenario: Filtering Opportunities by stage
    Given I am registered and logged in as annika
    And Prospecting stage exists
    And an opportunity exists with user: Annika, stage: Prospecting stage, title: "Prospecting Opportunity", assignee: Annika
    And Negotiation stage exists
    And an opportunity exists with user: Annika, stage: Negotiation stage, title: "Opportunity in Negotiation", assignee: Annika
    And I am on the dashboard page
    When I follow "Opportunities"
    And I check "Prospecting"
    And I press "Filter"
    Then I should be on the opportunities page
    And I should see "Prospecting Opportunity"
    And I should not see "Opportunity in Negotiation"

  Scenario: Filtering opportunities assigned to me
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And an opportunity exists with user: Annika, title: "Great Opportunity", assignee: Annika
    And an opportunity exists with user: Annika, title: "Benny's opportunity", assignee: Benny
    And I am on the dashboard page
    When I follow "Opportunities"
    And I check "Assigned to me"
    And I press "Filter"
    Then I should be on the opportunities page
    And I should see "Great Opportunity"
    And I should not see "Benny's opportunity"

  Scenario: Deleted opportunities
    Given I am registered and logged in as annika
    And an opportunity exists with user: Annika, deleted_at: "01/01/10", title: "An opportunity"
    And I am on the dashboard page
    When I follow "Opportunities"
    Then I should not see "An opportunity"

  Scenario: Viewing an opportunity
    Given I am registered and logged in as annika
    And an opportunity exists with user: Annika, title: "An opportunity"
    And I am on the opportunities page
    When I follow "An opportunity"
    Then I should be on the opportunity's page
    And I should see "An opportunity"
    And a view activity should have been created for opportunity with title "An opportunity"

  Scenario: Adding a task to an opportunity
    Given I am registered and logged in as annika
    And an opportunity exists with user: annika
    And I am on the opportunity's page
    And all emails have been delivered
    And I follow "add_task"
    And I follow "preset_date"
    And I fill in "task_name" with "Call to get offer details"
    And I select "As soon as possible" from "task_due_at"
    And I select "Call" from "task_category"
    When I press "Create Task"
    Then I should be on the opportunity's page
    And a task should have been created
    And I should see "Call to get offer details"
    And 0 emails should be delivered

  Scenario: Adding a task to an unassigned opportunity
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And an opportunity exists with user: Benny, assignee: nil
    And I am on the opportunity's page
    And all emails have been delivered
    And I follow "add_task"
    And I follow "preset_date"
    And I fill in "task_name" with "Call to get offer details"
    And I select "As soon as possible" from "task_due_at"
    And I select "Call" from "task_category"
    When I press "Create Task"
    Then I should be on the opportunity's page
    And a task should have been created
    And I should see "Call to get offer details"
    And 0 emails should be delivered
    And the opportunity should be assigned to Annika

  Scenario: Adding a contact to an opportunity
    Given I am registered and logged in as annika
    And an opportunity exists with user: Annika
    And a contact exists with user: Annika, first_name: "Hans", last_name: "Schmidt"
    And I am on the opportunity's page
    When I follow "Select Contact"
    And I select "Hans Schmidt" from "opportunity_contact_id"
    And I press "Update Opportunity"
    Then I should be on the opportunities page
    And the contact should have 1 opportunities
