Feature: User Authentication
  As a user of the CUHK Booking System
  I want to log in and log out
  So that I can access features appropriate to my role

  Background:
    Given the following users exist:
      | email              | password   | role           |
      | admin@link.cuhk.edu.hk  | Password1! | admin          |
      | staff@link.cuhk.edu.hk  | Password1! | staff          |
      | member@link.cuhk.edu.hk | Password1! | society_member |

  Scenario: Successful login as admin
    Given I am on the login page
    When I fill in "Email" with "admin@link.cuhk.edu.hk"
    And I fill in "Password" with "Password1!"
    And I press "Log in"
    Then I should see "Dashboard"
    And I should see "Admin"

  Scenario: Successful login as staff
    Given I am on the login page
    When I fill in "Email" with "staff@link.cuhk.edu.hk"
    And I fill in "Password" with "Password1!"
    And I press "Log in"
    Then I should see "Dashboard"
    And I should see "Staff"

  Scenario: Successful login as society member
    Given I am on the login page
    When I fill in "Email" with "member@link.cuhk.edu.hk"
    And I fill in "Password" with "Password1!"
    And I press "Log in"
    Then I should see "Dashboard"
    And I should see "Society Member"

  Scenario: Failed login with incorrect password
    Given I am on the login page
    When I fill in "Email" with "admin@link.cuhk.edu.hk"
    And I fill in "Password" with "wrongpassword"
    And I press "Log in"
    Then I should see "Invalid email or password"

  Scenario: Failed login with non-existent email
    Given I am on the login page
    When I fill in "Email" with "nobody@link.cuhk.edu.hk"
    And I fill in "Password" with "Password1!"
    And I press "Log in"
    Then I should see "Invalid email or password"

  Scenario: User logs out
    Given I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I click "Log out"
    Then I should be on the login page

  Scenario: Unauthenticated user is redirected to login
    When I try to visit the dashboard
    Then I should be on the login page
