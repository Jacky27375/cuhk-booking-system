Feature: Booking timetable and conflict prevention
  I want to book venues with a date-based timetable
  So that I can choose valid slots and avoid conflicts

  Background:
    Given there is a tenant "University"
    And there is a user "member@link.cuhk.edu.hk" with role "society_member"
    And there is a user "other@link.cuhk.edu.hk" with role "society_member"
    And there is a venue "Lecture Hall A"

  Scenario: Timetable shows booked and available slots for selected date
    Given there is a booking for "Lecture Hall A" by "other@example.com" from 5 days in the future at "10:00" to 5 days in the future at "11:00"
    And I am logged in as "member@link.cuhk.edu.hk"
    When I open the booking page for "Lecture Hall A" on a date 5 days in the future
    Then I should not see "Show Timetable"
    Then I should see timetable date for 5 days in the future
    And the slot "10:00 - 11:00" should be marked unavailable
    And the slot "11:00 - 12:00" should be marked available

  Scenario: Booking outside business hours is rejected
    Given I am logged in as "member@link.cuhk.edu.hk"
    When I open the booking page for "Lecture Hall A" on a date 5 days in the future
    And I select "08:00" from "Start time"
    And I select "08:00" from "End time"
    And I click "Review Booking"
    And I should not see "error prohibited this booking from being saved"
    Then I should see "must be after start time"

  Scenario: Booking with non hourly increments is rejected
    Given I am logged in as "member@link.cuhk.edu.hk"
    When I open the booking page for "Lecture Hall A" on a date 5 days in the future
    Then I should not see "09:15"
    And I should not see "09:30"
    And I should see "09:00"
    And I should see "10:00"

  Scenario: Overlapping booking is rejected
    Given there is a booking for "Lecture Hall A" by "other@link.cuhk.edu.hk" from 5 days in the future at "10:00" to 5 days in the future at "11:00"
    And I am logged in as "member@link.cuhk.edu.hk"
    When I open the booking page for "Lecture Hall A" on a date 5 days in the future
    And I select "10:00" from "Start time"
    And I select "12:00" from "End time"
    And I click "Review Booking"
    And I should not see "error prohibited this booking from being saved"
    Then I should see "conflicts with an existing booking"
    And the slot "10:00 - 11:00" should be marked unavailable
    And the slot "10:00 - 11:00" should not be marked selected

  Scenario: Selected slot is highlighted on edit page
    Given there is a booking for "Lecture Hall A" by "member@link.cuhk.edu.hk" from 5 days in the future at "12:00" to 5 days in the future at "13:00"
    And I am logged in as "member@link.cuhk.edu.hk"
    When I open the edit booking page for my booking on a date 5 days in the future
    Then the slot "12:00 - 13:00" should be marked selected