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
