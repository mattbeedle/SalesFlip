Feature: Manage users
  In order to manage their personal details and settings
  A User
  wants to manage themselves

  Scenario: Viewing your profile
    Given I am registered and logged in as annika
    And I am on the dashboard page
    When I follow "profile"
    Then I should see "annika.fleischer@1000jobboersen.de"
    And I should see "My Profile"
    And I should see "@salesflip.appspotmail.com"
    And an activity should not exist

  Scenario: Viewing your profile as a freelancer
    Given I am registered and logged in as Carsten Werner
    And I am on the dashboard page
    When I follow "My Profile"
    Then I should see "carsten.werner@1000jobboersen.de"

  Scenario: Inviting a user
    Given I am registered and logged in as annika
    And I am on the dashboard page
    And I follow "users"
    And I follow "invitations"
    And I follow "new"
    When I fill in "invitation_email" with "werner@1000jobboersen.de"
    And I select "Freelancer" from "invitation_role"
    And I press "invitation_submit"
    And all delayed jobs have finished
    Then I should be on the invitations page
    And I should see "werner@1000jobboersen.de"
    And 1 invitations should exist with email: "werner@1000jobboersen.de"
    And 1 emails should be delivered to "werner@1000jobboersen.de"

  Scenario: Accepting an invitation
    Given I have an invitation
    And I go to the accept invitation page
    And I fill in "user_username" with "Werner"
    And I fill in "user_password" with "password"
    And I fill in "user_password_confirmation" with "password"
    When I press "user_submit"
    Then 1 users should exist with username: "Werner"
    And I should be on the new user session page

  Scenario: Accepting a freelancer invitation
    Given I have a Freelancer invitation
    And I go to the accept invitation page
    And I fill in "user_username" with "Werner"
    And I fill in "user_password" with "password"
    And I fill in "user_password_confirmation" with "password"
    When I press "user_submit"
    Then 1 users should exist with username: "Werner", role: "Freelancer"
    And I should be on the new user session page

  Scenario: Accepted an invitation with errors
    Given I have an invitation
    And I go to the accept invitation page
    When I press "user_submit"
    Then I should be on the users page
    And I should see "can't be blank"
