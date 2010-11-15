Feature: Manage components
  
  @culerity
  Scenario: Register new component
    Given I am on the components page
    When I click "(Add Component)"
    And I fill in "Name" with "name 1"
    And I press "Save"
    Then I should see "name 1"
    And show me the page
    
  @culerity
  Scenario: Register invalid component
    Given I am on the components page
    When I click "(Add Component)"
    And I press "Save"
    Then show me the page
    Then I should see "There were problems"
    
  @culerity
  Scenario: Register invalid component then fix
    Given I am on the components page
    When I click "(Add Component)"
    And I press "Save"
    And I fill in "Name" with "name 1"
    And I press "Save"
    Then I should see "name 1"
    And I should not see "There were problems"
  
  @culerity
  Scenario: Edit component
    Given I am on the components page
    When I click "Edit" on the 1st component
    And I fill in "Name" with "new name"
    And I press "Save"
    Then I should see "new name"
  
  @culerity
  Scenario: Edit component invalidates component
    Given I am on the components page
    When I click "Edit" on the 1st component
    And I fill in "Name" with ""
    And I press "Save"
    Then I should see "There were problems"
    
  @culerity
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
