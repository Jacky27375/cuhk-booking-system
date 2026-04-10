Feature: Booking timetable and conflict prevention
  I want to book venues with a date-based timetable
  So that I can choose valid slots and avoid conflicts

  Background:
    Given there is a tenant "University"
    And there is a user "member@link.cuhk.edu.hk" with role "student"
    And there is a user "other@link.cuhk.edu.hk" with role "student"
    And there is a venue "Lecture Hall A"

  Scenario: Timetable shows booked and available slots for selected date
    Given there is a booking for "Lecture Hall A" by "other@link.cuhk.edu.hk" from 5 days in the future at "10:00" to 5 days in the future at "11:00"
    And I am logged in as "member@link.cuhk.edu.hk"
    When I open the booking page for "Lecture Hall A" on a date 5 days in the future
    Then I should not see "Show Timetable"
    Then I should see timetable date for 5 days in the future
    And the slot "10:00 - 11:00" should be marked unavailable
    And the slot "11:00 - 12:00" should be marked available

  @javascript
  Scenario: Unavailable start time options are hidden
    Given there is a booking for "Lecture Hall A" by "other@link.cuhk.edu.hk" from 5 days in the future at "08:00" to 5 days in the future at "10:00"
    And I am logged in as "member@link.cuhk.edu.hk"
    When I open the booking page for "Lecture Hall A" on a date 5 days in the future
    Then the "Start time" options should include:
      | 10:00 |
      | 11:00 |
    And the "Start time" options should not include:
      | 08:00 |
      | 09:00 |

  @javascript
  Scenario: End time appears only after start time and only shows valid slots
    Given there is a venue "Room B"
    And there is a booking for "Room B" by "other@link.cuhk.edu.hk" from 5 days in the future at "12:00" to 5 days in the future at "13:00"
    And I am logged in as "member@link.cuhk.edu.hk"
    When I open the booking page for "Room B" on a date 5 days in the future
    Then the end time picker should be disabled
    When I select "10:00" from "Start time"
    Then the end time picker should be enabled
    And the "End time" options should include:
      | 11:00 |
      | 12:00 |
    And the "End time" options should not include:
      | 13:00 |
      | 14:00 |
    When I select "19:00" from "Start time"
    Then the "End time" options should include:
      | 20:00 |
      | 21:00 |
      | 22:00 |
    And the "End time" options should not include:
      | 23:00 |


  Scenario: Booking with non hourly increments is rejected
    Given I am logged in as "member@link.cuhk.edu.hk"
    When I open the booking page for "Lecture Hall A" on a date 5 days in the future
    Then I should not see "09:15"
    And I should not see "09:30"
    And I should see "09:00"
    And I should see "10:00"

  Scenario: Selected slot is highlighted on edit page
    Given there is a booking for "Lecture Hall A" by "member@link.cuhk.edu.hk" from 5 days in the future at "12:00" to 5 days in the future at "13:00"
    And I am logged in as "member@link.cuhk.edu.hk"
    When I open the edit booking page for my booking on a date 5 days in the future
    Then the slot "12:00 - 13:00" should be marked selected