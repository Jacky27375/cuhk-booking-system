Feature: Sorting in list pages
  As a staff or admin user
  I want list pages to support three-state sorting from column headers
  So that I can switch between asc, desc, and default order

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
    And there is a user "admin.all@link.cuhk.edu.hk" with role "admin"
    And I am logged in as "admin.all@link.cuhk.edu.hk"

  Scenario: Venue list toggles sort by Name
    When I visit the venues page
    Then the first row in table "venues-table" should contain "New Asia Lounge"
    When I click "Name"
    Then the first row in table "venues-table" should contain "New Asia Lounge"
    When I click "Name (asc)"
    Then the first row in table "venues-table" should contain "Shaw Hall"
    When I click "Name (desc)"
    Then the first row in table "venues-table" should contain "New Asia Lounge"

  Scenario: Equipment list toggles sort by Name
    When I visit the equipments page
    Then the first row in table "equipments-table" should contain "NA Projector"
    When I click "Name"
    Then the first row in table "equipments-table" should contain "NA Projector"
    When I click "Name (asc)"
    Then the first row in table "equipments-table" should contain "Shaw Projector"
    When I click "Name (desc)"
    Then the first row in table "equipments-table" should contain "NA Projector"

  Scenario: Bookings list toggles sort by Resource
    When I visit the bookings page
    Then the first row in table "bookings-table" should contain "Shaw Hall"
    When I click "Resource"
    Then the first row in table "bookings-table" should contain "New Asia Lounge"
    When I click "Resource (asc)"
    Then the first row in table "bookings-table" should contain "Shaw Hall"
    When I click "Resource (desc)"
    Then the first row in table "bookings-table" should contain "Shaw Hall"

  Scenario: Approval dashboard toggles sort by Venue
    When I visit the approval dashboard
    Then the first row in table "approvals-table" should contain "Shaw Hall"
    When I click "Venue"
    Then the first row in table "approvals-table" should contain "New Asia Lounge"
    When I click "Venue (asc)"
    Then the first row in table "approvals-table" should contain "Shaw Hall"

  Scenario: List pages render tables with grid styling
    When I visit the venues page
    Then table "venues-table" should have class "resource-grid-table"
    When I visit the equipments page
    Then table "equipments-table" should have class "resource-grid-table"
    When I visit the bookings page
    Then table "bookings-table" should have class "resource-grid-table"
    When I visit the approval dashboard
    Then table "approvals-table" should have class "resource-grid-table"
