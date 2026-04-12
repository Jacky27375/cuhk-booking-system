Feature: Venue Booking System
  As a user of the CUHK Booking System
  I want to be able to book venues and manage venue bookings
  So that I can organize events efficiently

  Background:
    Given there is a tenant "University"
    And there is a user "admin@link.cuhk.edu.hk" with role "admin"
    And there is a user "staff@link.cuhk.edu.hk" with role "staff"
    And there is a user "member@link.cuhk.edu.hk" with role "student"

  Scenario: Admin can create a new venue
    Given I am logged in as "admin@link.cuhk.edu.hk"
    When I visit the venues page
    And I click "New Venue"
    And I fill in "Name" with "Lecture Hall A"
    And I fill in "Description" with "A large lecture hall"
    And I select "University" from "Department"
    And I click "Create Venue"
    Then I should see "Venue was successfully created."
    And I should see "Lecture Hall A"

  Scenario: Staff can create a new venue
    Given I am logged in as "staff@link.cuhk.edu.hk"
    When I visit the venues page
    And I click "New Venue"
    And I fill in "Name" with "Conference Room B"
    And I fill in "Description" with "A medium-sized conference room"
    And I select "University" from "Department"
    And I click "Create Venue"
    Then I should see "Venue was successfully created."

  Scenario: Member can view list of venues
    Given there is a venue "Lecture Hall A"
    And I am logged in as "member@link.cuhk.edu.hk"
    When I visit the venues page
    Then I should see "Lecture Hall A"
    And I should not see "New Venue"
    And I should not see "Edit"
    And I should not see "Destroy"

  Scenario: Member can book a venue
    Given there is a venue "Lecture Hall A"
    And I am logged in as "member@link.cuhk.edu.hk"
    When I visit the venues page
    And I click "Lecture Hall A"
    And I click "Book Venue"
    And I fill in "booking_date" with a date 5 days in the future
    And I select "10:00" from "booking_start_slot"
    And I select "12:00" from "booking_end_slot"
    And I click "Review Booking"
    Then I should see "Booking Summary"
    And I should see "Lecture Hall A"
    And I should see "10:00 - 12:00"
    When I click "Submit Booking"
    Then I should see "Booking was successfully created."
    And I should see "Booking was successfully created." only once

  Scenario: Admin cannot book a venue
    Given there is a venue "Lecture Hall A"
    And I am logged in as "admin@link.cuhk.edu.hk"
    When I visit the venues page
    And I click "Lecture Hall A"
    Then I should not see "Book Venue"

  Scenario: Staff cannot book a venue
    Given there is a venue "Lecture Hall A"
    And I am logged in as "staff@link.cuhk.edu.hk"
    When I visit the venues page
    And I click "Lecture Hall A"
    Then I should not see "Book Venue"

  Scenario: Admin can see booking requests
    Given there is a venue "Lecture Hall A"
    And there is a booking for "Lecture Hall A" by "member@link.cuhk.edu.hk" from 5 days in the future at "10:00" to 5 days in the future at "12:00"
    And I am logged in as "admin@link.cuhk.edu.hk"
    When I visit the bookings page
    Then I should see "Lecture Hall A"
    And I should see "member@link.cuhk.edu.hk"

  # Constraint: Venues can only be booked at least 5 days in advance
  Scenario: Member can book a venue exactly 5 days in advance
    Given there is a venue "Lecture Hall A"
    And I am logged in as "member@link.cuhk.edu.hk"
    When I visit the venues page
    And I click "Lecture Hall A"
    And I click "Book Venue"
    And I fill in "booking_date" with a date 5 days in the future
    And I select "10:00" from "booking_start_slot"
    And I select "12:00" from "booking_end_slot"
    And I click "Review Booking"
    Then I should see "Booking Summary"
    When I click "Submit Booking"
    Then I should see "Booking was successfully created."

  Scenario: Member cannot book a venue less than 5 days in advance
    Given there is a venue "Lecture Hall A"
    And I am logged in as "member@link.cuhk.edu.hk"
    When I visit the venues page
    And I click "Lecture Hall A"
    And I click "Book Venue"
    And I fill in "booking_date" with a date 4 days in the future
    And I select "10:00" from "booking_start_slot"
    And I select "12:00" from "booking_end_slot"
    And I click "Review Booking"
    Then I should see "Venue must be booked at least 5 days in advance"

  # Constraint: Venues can be booked for at most 4 hours
  Scenario: Member can book a venue for up to 4 hours
    Given there is a venue "Lecture Hall A"
    And I am logged in as "member@link.cuhk.edu.hk"
    When I visit the venues page
    And I click "Lecture Hall A"
    And I click "Book Venue"
    And I fill in "booking_date" with a date 5 days in the future
    And I select "10:00" from "booking_start_slot"
    And I select "14:00" from "booking_end_slot"
    And I click "Review Booking"
    Then I should see "Booking Summary"
    When I click "Submit Booking"
    Then I should see "Booking was successfully created."

  Scenario: Member cannot select an end time beyond 4 hours
    Given there is a venue "Lecture Hall A"
    And I am logged in as "member@link.cuhk.edu.hk"
    When I visit the venues page
    And I click "Lecture Hall A"
    And I click "Book Venue"
    And I fill in "booking_date" with a date 5 days in the future
    And I select "10:00" from "booking_start_slot"
    Then the "booking_end_slot" options should include:
      | 11:00 |
      | 12:00 |
      | 13:00 |
      | 14:00 |
    And the "booking_end_slot" options should not include:
      | 15:00 |

  # Constraint: Each student can book at most 2 venues per day
  Scenario: Member cannot book more than 2 venues on the same day
    Given there is a venue "Lecture Hall A"
    And there is a venue "Lecture Hall B"
    And there is a venue "Lecture Hall C"
    And there are 2 existing bookings for "member@link.cuhk.edu.hk" on a date 5 days in the future
    And I am logged in as "member@link.cuhk.edu.hk"
    When I visit the venues page
    And I click "Lecture Hall A"
    And I click "Book Venue"
    And I fill in "booking_date" with a date 5 days in the future
    And I select "10:00" from "booking_start_slot"
    And I select "12:00" from "booking_end_slot"
    And I click "Review Booking"
    Then I should see "You can book at most 2 venues per day"
