Feature: User Authentication
  As a CUHK member
  I want to log in and out of the system
  So that my bookings and data are kept secure

  Background:
    Given the following users exist:
      | email                  | password   | role    |
      | student@cuhk.edu.hk    | password1  | student |
      | staff@cuhk.edu.hk      | password1  | staff   |
      | admin@cuhk.edu.hk      | password1  | admin   |

  Scenario: Student logs in successfully
    Given I am on the login page
    When I fill in "Email" with "student@cuhk.edu.hk"
    And I fill in "Password" with "password1"
    And I click "Log In"
    Then I should see "Welcome back"
    And I should be on the student dashboard

  Scenario: User logs in with wrong password
    Given I am on the login page
    When I fill in "Email" with "student@cuhk.edu.hk"
    And I fill in "Password" with "wrongpassword"
    And I click "Log In"
    Then I should see "Invalid email or password"

  Scenario: Student cannot access staff dashboard
    Given I am logged in as "student@cuhk.edu.hk"
    When I visit the staff dashboard
    Then I should see "Access Denied"
    And I should be redirected to the student dashboard

  Scenario: User logs out
    Given I am logged in as "student@cuhk.edu.hk"
    When I click "Log Out"
    Then I should be on the login page
    And I should see "You have been logged out"
