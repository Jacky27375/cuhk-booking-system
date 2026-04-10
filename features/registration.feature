Feature: Student registration
  As a new student
  I want to sign up using a CUHK college
  So that only valid college tenants can be selected

  Background:
    Given the registration college tenants exist

  Scenario: Registration form shows only allowed college tenants
    When I am on the registration page
    Then the college dropdown should include only:
      | Chung Chi College |
      | New Asia College |
      | United College |
      | Shaw College |
      | Morningside College |
      | S.H. Ho College |
      | CW Chu College |
      | Wu Yee Sun College |
      | Lee Woo Sing College |
    And the college dropdown should not include "University"

  Scenario: Student cannot register under a disallowed tenant
    Given there is a tenant "University"
    When I submit registration with tenant "University"
    Then I should see "Tenant must be one of the eligible CUHK colleges"
    And no user should exist with email "blocked@link.cuhk.edu.hk"

  Scenario: Student completes signup after email code verification
    When I am on the registration page
    And I fill in "CUHK Email" with "verified"
    And I fill in "Password" with "Password1!"
    And I fill in "Confirm Password" with "Password1!"
    And I select "Chung Chi College" from "College"
    And I press "Send Verification Code"
    Then I should see "Verification code sent to verified@link.cuhk.edu.hk."
    When I enter the latest signup verification code
    And I press "Verify and Create Account"
    Then I should see "Account created successfully."

  Scenario: Invalid verification code blocks account creation
    When I am on the registration page
    And I fill in "CUHK Email" with "invalidcode"
    And I fill in "Password" with "Password1!"
    And I fill in "Confirm Password" with "Password1!"
    And I select "New Asia College" from "College"
    And I press "Send Verification Code"
    And I fill in "Verification Code" with "000000"
    And I press "Verify and Create Account"
    Then I should see "Invalid verification code. Attempts remaining:"
    And no user should exist with email "invalidcode@link.cuhk.edu.hk"
