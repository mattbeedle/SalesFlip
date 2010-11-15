# Feature: Manage activity feeds
#   In order to keep track of what has been done, and easily manage related items
#   A User
#   wants to keep an activity history of related contacts, tasks and comments
# 
#   Scenario: Viewing activities for an account
#     Given I am registered and logged in as annika
#     And account: "careermee" exists with user: annika
#     And account: "careermee" exists with user: Annika
#     And I am on the account's page
#     When I follow "Add Contact"
#     And I fill in "First Name" with "Matt"
#     And I fill in "Last Name" with "Beedle"
#     And I press "contact_submit"
#     Then I should be on the account's page
#     And I should see "Matt Beedle"