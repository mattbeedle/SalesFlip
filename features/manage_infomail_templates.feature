Feature: User manages infomail templates

  Scenario: success
    Given I am registered and logged in as Matt
    When I go to the infomail templates page
    And I follow "New"
    Then I should be on the new infomail template page

    When I fill in "Name" with "Generic Template"
    And I fill in "Subject" with "An introduction to 1000jobboersen.de"
    And I fill in "Body" with "Thanks for your interest. Here's some details about us."
    And I press "Create"
    Then I should see "Generic Template"

    When I go to the infomail templates page
    Then I should see "Generic Template"

    When I follow "Generic Template"
    And I follow "Edit"
    And I fill in "Name" with "Default Template"
    And I press "Update"
    Then I should see "Default Template"

    ## Why doesn't uploading attachments work?
    #
    # When I follow "Edit"
    # And I attach the file "test/support/AboutStacks.pdf" to "Attachment 1"
    # And I press "Update"
    # Then I should see "AboutStacks"

    Given a campaign: "generate_leads" exists
    When I follow "Edit"
    And I select "Generate 100 leads this month" from "Campaign"
    And I press "Update"
    Then I should see "Generate 100 leads this month"
