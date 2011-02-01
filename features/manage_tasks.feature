Feature: Manage tasks
  In order to remember to do jobs
  A User
  wants to add, update, delete and be reminded of tasks

  Scenario: Tasks on the dashboard
    Given I am registered and logged in as annika
    And Benny exists
    And a task exists with user: Annika, name: "Task for Annika"
    And a task exists with user: Benny, name: "Task for Benny"
    And a task exists with user: Annika, name: "Completed Task for Annika", completed_at: "10 Oct 2009"
    And a task exists with user: Annika, name: "Future Task for Annika", due_at: "10 Oct 3000"
    When I am on the dashboard page
    Then I should see "Task for Annika" within "#tasks"
    And I should not see "Task for Benny" within "#tasks"
    And I should not see "Completed Task for Annika" within "#tasks"
    And I should not see "Future Task for Annika" within "#tasks"
    And I should see "As soon as possible" within "#tasks"
    And I should not see "You have no outstanding tasks" within "#tasks"

  Scenario: Tasks on the dashboard when there are no tasks
    Given I am registered and logged in as annika
    When I am on the dashboard page
    Then I should not see "As soon as possible" within "#tasks"
    And I should not see "Today" within "#tasks"
    And I should see "You have no outstanding tasks" within "#tasks"

  Scenario: Creating a new task
    Given I am registered and logged in as annika
    And I am on the tasks page
    And I follow "new"
    And I follow "preset_date"
    And I fill in "task_name" with "a test task"
    And I select "Call" from "task_category"
    And I select "Today" from "task_due_at"
    When I press "task_submit"
    Then I should be on the tasks page
    And I should see "a test task"

  Scenario: Assigning a new task to a user, with a lead, when the lead is private
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And a lead exists with user: Annika, permission: "Private"
    And I am on the lead's page
    When I follow "Add Task"
    And I follow "preset_date"
    And I fill in "task_name" with "a test task"
    And I select "Call" from "task_category"
    And I select "Today" from "task_due_at"
    And I select "benjamin.pochhammer@1000jobboersen.de" from "task_assignee_id"
    And I press "Create Task"
    Then 0 tasks should exist
    And I should see "Cannot assign this task to anyone else because the lead that it is associated with is private. Please change the lead permission first"

  Scenario: Assigning a new task to a user, with an account, when the account is private
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And an account exists with user: Annika, permission: "Private"
    And I am on the account's page
    When I follow "Add Task"
    And I follow "preset_date"
    And I fill in "task_name" with "a test task"
    And I select "Call" from "task_category"
    And I select "Today" from "task_due_at"
    And I select "benjamin.pochhammer@1000jobboersen.de" from "task_assignee_id"
    And I press "Create Task"
    Then 0 tasks should exist
    And I should see "Cannot assign this task to anyone else because the account that it is associated with is private. Please change the account permission first"

  Scenario: Assigning a new task to a user, with a contact, when the contact is private
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And a contact exists with user: Annika, permission: "Private"
    And I am on the contact's page
    When I follow "Add Task"
    And I follow "preset_date"
    And I fill in "task_name" with "a test task"
    And I select "Call" from "task_category"
    And I select "Today" from "task_due_at"
    And I select "benjamin.pochhammer@1000jobboersen.de" from "task_assignee_id"
    And I press "Create Task"
    Then 0 tasks should exist
    And I should see "Cannot assign this task to anyone else because the contact that it is associated with is private. Please change the contact permission first"

  Scenario: Assigning a new task to a user, with a lead, when the lead is not shared with them
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And another user exists
    And a lead exists with user: Annika
    And the lead is shared with the other user
    And I am on the lead's page
    When I follow "Add Task"
    And I follow "preset_date"
    And I fill in "Subject" with "a test task"
    And I select "Call" from "task_category"
    And I select "Today" from "task_due_at"
    And I select "benjamin.pochhammer@1000jobboersen.de" from "Assignee"
    And I press "Create Task"
    Then 0 tasks should exist
    And I should see "Cannot assign this task to benjamin.pochhammer@1000jobboersen.de because the lead associated with it is not shared with that user"

  Scenario: Assigning a new task to a user, with an account, when the account is not shared with them
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And another user exists
    And an account exists with user: Annika
    And the account is shared with the other user
    And I am on the account's page
    When I follow "Add Task"
    And I follow "preset_date"
    And I fill in "Subject" with "a test task"
    And I select "Call" from "task_category"
    And I select "Today" from "task_due_at"
    And I select "benjamin.pochhammer@1000jobboersen.de" from "Assignee"
    And I press "Create Task"
    Then 0 tasks should exist
    And I should see "Cannot assign this task to benjamin.pochhammer@1000jobboersen.de because the account associated with it is not shared with that user"

  Scenario: Assigning an existing task to a user, with a contact, when the contact is private
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And a contact exists with user: Annika, permission: "Private"
    And a task exists with user: Annika, asset: contact, assignee: Annika
    And I am on the contact's page
    When I go to the task's edit page
    And I select "benjamin.pochhammer@1000jobboersen.de" from "task_assignee_id"
    And I press "Update Task"
    Then I should see "Cannot assign this task to anyone else because the contact that it is associated with is private. Please change the contact permission first"
    And the task should be assigned to Annika

  Scenario: Viewing my tasks
    Given I am registered and logged in as annika
    And a task exists with user: annika, name: "Task for Annika"
    And Annika has invited Benny
    And a task exists with user: benny, name: "Task for Benny"
    And I am on the dashboard page
    When I follow "Tasks"
    Then I should see "Task for Annika"
    And I should not see "Task for Benny"

  Scenario: Re-assiging a task
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And a task: "call_erich" exists with user: annika
    And all emails have been delivered
    And I follow "Tasks"
    And I follow the edit link for the task
    And I follow "preset_date"
    When I select "benjamin.pochhammer@1000jobboersen.de" from "task_assignee_id"
    And I select "Today" from "task_due_at"
    And I press "update_task"
    And all delayed jobs have finished
    Then I should be on the tasks page
    And I should see "Task has been re-assigned"
    And a task re-assignment email should have been sent to "benjamin.pochhammer@1000jobboersen.de"

  Scenario: Filtering pending tasks
    Given I am registered and logged in as annika
    And a task: "call_erich" exists with user: annika
    And a task exists with user: annika, name: "test task", completed_at: "12th March 2000"
    And I am on the tasks page
    When I follow "pending"
    Then I should see "erich"
    And I should not see "test task"

  Scenario: Filtering assigned tasks
    Given I am registered and logged in as annika
    And Annika has invited Benny
    And a task: "call_erich" exists with user: annika
    And a task exists with user: annika, assignee: annika, name: "annika's task"
    And a task exists with user: benny, assignee: benny, name: "benny's task"
    And a task exists with user: benny, assignee: annika, name: "task for annika"
    And a task exists with user: annika, assignee: benny, name: "a task for benny"
    When I am on the tasks page
    And I follow "assigned"
    Then I should not see "Erich"
    And I should not see "annika's task"
    And I should not see "benny's task"
    And I should not see "task for annika"
    And I should see "a task for benny"

  Scenario: Filtering overdue pending tasks
    Given I am registered and logged in as annika
    And a task: "call_erich" exists with user: annika, due_at: "overdue"
    And a task exists with user: annika, name: "another task", due_at: "due_next_week"
    When I am on the tasks page
    And I follow "pending"
    And I check "overdue"
    And I press "filter"
    Then I should see "erich"
    And I should not see "another task"

  Scenario: Filtering pending tasks due today
    Given I am registered and logged in as annika
    And a task "call_erich" exists with user: annika, due_at: "due_today"
    And a task exists with user: annika, name: "another task", due_at: "due_next_week"
    When I am on the tasks page
    And I follow "pending"
    And I check "due_today"
    And I press "filter"
    Then I should see "erich"
    And I should not see "another task"

  Scenario: Filtering pending tasks due tomorrow
    Given I am registered and logged in as annika
    And a task "call_erich" exists with user: annika, due_at: "due_tomorrow"
    And a task exists with user: annika, name: "another task", due_at: "due_next_week"
    When I am on the tasks page
    And I follow "pending"
    And I check "due_tomorrow"
    And I press "filter"
    Then I should see "erich"
    And I should not see "another task"

  Scenario: Filtering pending tasks due next week
    Given I am registered and logged in as annika
    And a task: "call_erich" exists with user: annika, due_at: "overdue"
    And a task exists with user: annika, name: "another task", due_at: "due_next_week"
    When I am on the tasks page
    And I follow "pending"
    And I check "due_next_week"
    And I press "filter"
    Then I should see "another task"
    And I should not see "erich"

  Scenario: Filtering pending tasks due later
    Given I am registered and logged in as annika
    And a task: "call_erich" exists with user: annika, due_at: "overdue"
    And a task exists with user: annika, name: "another task", due_at: "due_later"
    When I am on the tasks page
    And I follow "pending"
    And I check "due_later"
    And I press "filter"
    Then I should see "another task"
    And I should not see "erich"

  Scenario: Filtering several pending tasks
    Given I am registered and logged in as annika
    And a task: "call_erich" exists with user: annika, due_at: "overdue"
    And a task exists with user: annika, name: "another task", due_at: "due_later"
    And a task exists with user: annika, name: "third task", due_at: "due_next_week"
    When I am on the tasks page
    And I follow "pending"
    And I check "overdue"
    And I check "due_later"
    And I press "filter"
    Then I should see "another task"
    And I should see "erich"
    And I should not see "third task"

  # TODO get this working with mongoDB, currently tries to use ActiveRecord for some weird reason
  #@javascript
  #Scenario: Completing a task
  #  Given I am registered and logged in as annika
  #  And a task: "call_erich" exists with user: annika, due_at: "overdue"
  #  When I am on the tasks page
  #  And I check task: "call_erich"
  #  Then I should not see "Edit"
  #  And I should not see "delete_task"
  #  And a task exists with user: annika, name: "call_erich", completed_at: !nil
