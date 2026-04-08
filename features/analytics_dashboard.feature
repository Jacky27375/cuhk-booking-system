@analytics
Feature: Analytics Dashboard
  As an admin or staff member
  I want to view analytics data about bookings and equipment
  So that I can make data-driven decisions

  Background:
    Given the following users exist:
      | email                    | password   | role           |
      | admin@link.cuhk.edu.hk  | Password1! | admin          |
      | staff@link.cuhk.edu.hk  | Password1! | staff          |
      | member@link.cuhk.edu.hk | Password1! | society_member |

  Scenario: Admin can access analytics dashboard
    Given I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I visit the analytics page
    Then I should see "Analytics Dashboard"

  Scenario: Staff can access analytics dashboard
    Given I am logged in as "staff@link.cuhk.edu.hk" with password "Password1!"
    When I visit the analytics page
    Then I should see "Analytics Dashboard"

  Scenario: Society member cannot access analytics dashboard
    Given I am logged in as "member@link.cuhk.edu.hk" with password "Password1!"
    When I visit the analytics page
    Then I should see "You are not authorized"

  Scenario: Analytics page shows summary statistics
    Given I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I visit the analytics page
    Then I should see "Total Bookings"
    And I should see "Pending"
    And I should see "Approved"
    And I should see "Venues"
    And I should see "Equipment"

  Scenario: Analytics page shows chart sections
    Given I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I visit the analytics page
    Then I should see "Bookings per Venue"
    And I should see "Booking Status Distribution"
    And I should see "Daily Bookings Trend"
    And I should see "Peak Booking Hours"
    And I should see "Equipment Borrow Count"

  Scenario: Analytics page has date range filter
    Given I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I visit the analytics page
    Then I should see "From:"
    And I should see "Reset"

  Scenario: Dashboard shows analytics link for admin
    Given I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I try to visit the dashboard
    Then I should see link "Analytics"

  Scenario: Dashboard shows analytics link for staff
    Given I am logged in as "staff@link.cuhk.edu.hk" with password "Password1!"
    When I try to visit the dashboard
    Then I should see link "Analytics"

  Scenario: Dashboard hides analytics link for member
    Given I am logged in as "member@link.cuhk.edu.hk" with password "Password1!"
    When I try to visit the dashboard
    Then I should not see link "Analytics"
