Feature: Role-based Access Control
  As a system administrator
  I want to restrict access based on user roles
  So that users can only access appropriate features

  Background:
    Given the following users exist:
      | email              | password   | role           |
      | admin@link.cuhk.edu.hk  | Password1! | admin          |
      | staff@link.cuhk.edu.hk  | Password1! | staff          |
      | member@link.cuhk.edu.hk | Password1! | society_member |

  Scenario: Admin can access admin panel
    Given I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I visit the admin panel
    Then I should see "Admin Panel"

  Scenario: Staff cannot access admin panel
    Given I am logged in as "staff@link.cuhk.edu.hk" with password "Password1!"
    When I visit the admin panel
    Then I should see "You are not authorized"

  Scenario: Society member cannot access admin panel
    Given I am logged in as "member@link.cuhk.edu.hk" with password "Password1!"
    When I visit the admin panel
    Then I should see "You are not authorized"

  Scenario: Society member dashboard hides Booking link
    Given I am logged in as "member@link.cuhk.edu.hk" with password "Password1!"
    When I try to visit the dashboard
    Then I should not see link "Booking"
    And I should see link "My Bookings"

  Scenario: Staff dashboard hides My Bookings link
    Given I am logged in as "staff@link.cuhk.edu.hk" with password "Password1!"
    When I try to visit the dashboard
    Then I should see link "Booking"
    And I should not see link "My Bookings"

  Scenario: Admin dashboard hides My Bookings link
    Given I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I try to visit the dashboard
    Then I should see link "Booking"
    And I should not see link "My Bookings"

  Scenario: Staff cannot access My Bookings page directly
    Given I am logged in as "staff@link.cuhk.edu.hk" with password "Password1!"
    When I visit my bookings page
    Then I should see "Only students can access My Bookings."

  Scenario: Admin cannot access My Bookings page directly
    Given I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I visit my bookings page
    Then I should see "Only students can access My Bookings."

  Scenario: Staff cannot edit a booking
    Given there is a venue "Lecture Hall A"
    And there is a booking for "Lecture Hall A" by "member@link.cuhk.edu.hk" from "2026-04-20 10:00:00" to "2026-04-20 12:00:00"
    And I am logged in as "staff@link.cuhk.edu.hk" with password "Password1!"
    When I try to edit the booking for "Lecture Hall A" on "2026-04-20"
    Then I should see "Staff and admin cannot edit bookings."

  Scenario: Admin cannot edit a booking
    Given there is a venue "Lecture Hall A"
    And there is a booking for "Lecture Hall A" by "member@link.cuhk.edu.hk" from "2026-04-20 10:00:00" to "2026-04-20 12:00:00"
    And I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I try to edit the booking for "Lecture Hall A" on "2026-04-20"
    Then I should see "Staff and admin cannot edit bookings."
