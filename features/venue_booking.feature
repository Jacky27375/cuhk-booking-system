Feature: Venue Booking System
  As a user of the CUHK Booking System
  I want to be able to book venues and manage venue bookings
  So that I can organize events efficiently

  Background:
    Given there is a tenant "University"
    And there is a society "Computer Science Society"
    And there is a user "admin@example.com" with role "admin"
    And there is a user "staff@example.com" with role "staff"
    And there is a user "member@example.com" with role "society_member"

  Scenario: Admin can create a new venue
    Given I am logged in as "admin@example.com"
    When I visit the venues page
    And I click "New Venue"
    And I fill in "Name" with "Lecture Hall A"
    And I fill in "Description" with "A large lecture hall"
    And I select "University" from "Department"
    And I click "Create Venue"
    Then I should see "Venue was successfully created."
    And I should see "Lecture Hall A"

  Scenario: Staff can create a new venue
    Given I am logged in as "staff@example.com"
    When I visit the venues page
    And I click "New Venue"
    And I fill in "Name" with "Conference Room B"
    And I fill in "Description" with "A medium-sized conference room"
    And I select "University" from "Department"
    And I click "Create Venue"
    Then I should see "Venue was successfully created."

  Scenario: Member can view list of venues
    Given there is a venue "Lecture Hall A"
    And I am logged in as "member@example.com"
    When I visit the venues page
    Then I should see "Lecture Hall A"
    And I should not see "New Venue"
    And I should not see "Edit"
    And I should not see "Destroy"

  Scenario: Member can book a venue
    Given there is a venue "Lecture Hall A"
    And I am logged in as "member@example.com"
    When I visit the venues page
    And I click "Lecture Hall A"
    And I click "Book Venue"
    And I select "10:00" from "Start time"
    And I select "12:00" from "End time"
    And I click "Review Booking"
    Then I should see "Confirm booking details"
    And I should see "Lecture Hall A"
    And I should see "Time period: 10:00 - 12:00"
    When I click "Submit Booking"
    Then I should see "Booking was successfully created."
    And I should see "Booking was successfully created." only once

  Scenario: Admin cannot book a venue
    Given there is a venue "Lecture Hall A"
    And I am logged in as "admin@example.com"
    When I visit the venues page
    And I click "Lecture Hall A"
    Then I should not see "Book Venue"

  Scenario: Staff cannot book a venue
    Given there is a venue "Lecture Hall A"
    And I am logged in as "staff@example.com"
    When I visit the venues page
    And I click "Lecture Hall A"
    Then I should not see "Book Venue"

  Scenario: Admin can see booking requests
    Given there is a venue "Lecture Hall A"
    And there is a booking for "Lecture Hall A" by "member@example.com" from "2026-03-20 10:00:00" to "2026-03-20 12:00:00"
    And I am logged in as "admin@example.com"
    When I visit the bookings page
    Then I should see "Lecture Hall A"
    And I should see "member@example.com"
    And I should see "2026-03-20 10:00:00"
