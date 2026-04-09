Feature: Staff Account Management
  As a root college staff member
  I want to create staff accounts for my college
  So that other staff can manage bookings and resources

  Background:
    Given the following college tenants exist:
      | name              |
      | Chung Chi College |
      | Shaw College      |
    And the following users exist:
      | email                                    | password   | role  |
      | admin@link.cuhk.edu.hk                   | Password1! | admin |
    And a root staff account "staff_root_chungchi@link.cuhk.edu.hk" exists for "Chung Chi College"

  Scenario: Root staff can access staff accounts page
    Given I am logged in as "staff_root_chungchi@link.cuhk.edu.hk" with password "Password1!"
    When I visit the staff accounts page
    Then I should see "Staff Accounts"

  Scenario: Root staff can create a new staff account
    Given I am logged in as "staff_root_chungchi@link.cuhk.edu.hk" with password "Password1!"
    When I visit the new staff account page
    And I fill in "CUHK Email" with "newstaff@link.cuhk.edu.hk"
    And I fill in "Password" with "Password1!"
    And I fill in "Confirm Password" with "Password1!"
    And I press "Create Staff Account"
    Then I should see "Staff account created successfully"
    And "newstaff@link.cuhk.edu.hk" should be a staff member of "Chung Chi College"

  Scenario: Non-root staff cannot access staff accounts
    Given a regular staff "regularstaff@link.cuhk.edu.hk" exists for "Chung Chi College"
    And I am logged in as "regularstaff@link.cuhk.edu.hk" with password "Password1!"
    When I visit the staff accounts page
    Then I should see "You are not authorized"

  Scenario: Student cannot access staff accounts
    Given a student "student@link.cuhk.edu.hk" exists for "Chung Chi College"
    And I am logged in as "student@link.cuhk.edu.hk" with password "Password1!"
    When I visit the staff accounts page
    Then I should see "You are not authorized"

  Scenario: Root staff sees only their own college staff
    Given a regular staff "otherstaff@link.cuhk.edu.hk" exists for "Shaw College"
    And I am logged in as "staff_root_chungchi@link.cuhk.edu.hk" with password "Password1!"
    When I visit the staff accounts page
    Then I should not see "otherstaff@link.cuhk.edu.hk"
