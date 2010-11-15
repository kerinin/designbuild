Feature: Manage components
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new component
    Given I am on the components page
    When I click "(Add Component)"
    And I fill in "Name" with "name 1"
    And I press "Save"
    Then I should see "name 1"

  Scenario: Edit component
    Given I am on the components page
    When I click "Edit" on the 1st component
    And I fill in "Name" with "new name"
    And I press "Save"
    Then I should see "new name"
    
  Scenario: Delete component
    Given the following components:
      |name|project_id|
      |name 1|1|
      |name 2|1|
      |name 3|1|
      |name 4|1|
    When I am on the components page of project 1
    And I click "Destroy" on the 3rd component
    Then I should see the following components:
      |name 1|
      |name 2|
      |name 4|
