Feature: Tenant access control for staff and admin
  As a CUHK booking system operator
  I want staff to see only their own tenant resources
  So that tenant data remains isolated while admins can supervise everything

  Background:
    Given the following tenants exist:
      | name             |
      | Shaw College     |
      | New Asia College |
    And the following venues exist:
      | name            | tenant           | department       |
      | Shaw Hall       | Shaw College     | Shaw College     |
      | New Asia Lounge | New Asia College | New Asia College |
    And the following equipments exist:
      | name           | tenant           | quantity |
      | Shaw Projector | Shaw College     | 5        |
      | NA Projector   | New Asia College | 5        |
    And the following pending bookings exist:
      | venue           | user_email              |
      | Shaw Hall       | booker.shaw@link.cuhk.edu.hk |
      | New Asia Lounge | booker.na@link.cuhk.edu.hk   |

  Scenario: Staff can only see resources from their own tenant
    Given I am logged in as a "staff" of "Shaw College"
    When I visit the venues page
    Then I should see "Shaw Hall"
    And I should not see "New Asia Lounge"
    When I visit the equipments page
    Then I should see "Shaw Projector"
    And I should not see "NA Projector"
    When I visit the bookings page
    Then I should see "Shaw Hall"
    And I should not see "New Asia Lounge"

  Scenario: Admin can see resources from all tenants
    Given there is a user "admin.all@link.cuhk.edu.hk" with role "admin"
    And I am logged in as "admin.all@link.cuhk.edu.hk"
    When I visit the venues page
    Then I should see "Shaw Hall"
    And I should see "New Asia Lounge"
    When I visit the equipments page
    Then I should see "Shaw Projector"
    And I should see "NA Projector"
    When I visit the bookings page
    Then I should see "Shaw Hall"
    And I should see "New Asia Lounge"
