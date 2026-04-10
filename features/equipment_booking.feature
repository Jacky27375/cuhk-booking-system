@equipment_booking
Feature: Equipment Booking
  As a student
  I want to borrow equipment from a department
  So that I can use it for my society's activities

  Background:
    Given I am logged in as "student@link.cuhk.edu.hk"
    And the following equipment exists:
      | name          | department       | quantity |
      | Projector     | Science Faculty  | 3        |
      | Microphone    | Arts Faculty     | 5        |
      | Laptop        | Engineering Dept | 2        |

  Scenario: Student views available equipment
    When I visit the equipment page
    Then I should see "Projector"
    And I should see "3 available"

  Scenario: Student successfully borrows available equipment
    When I borrow 1 "Projector" from 5 days from now to 6 days from now
    Then I should see "Equipment booking submitted"
    And the available count for "Projector" should show 2

  Scenario: Student cannot borrow more than available quantity
    When I borrow 5 "Laptop" from 5 days from now to 6 days from now
    Then I should see "Not enough units available"

  Scenario: Staff returns equipment
    Given I have an approved loan of 1 "Projector" ending today
    And I am logged in as "staff@link.cuhk.edu.hk" with password "Password1!"
    When I mark the "Projector" as returned
    Then the available count for "Projector" should be restored
    And the booking for "Projector" should show status "Returned" in all bookings

  # Constraint: Equipment can only be booked at least 5 days in advance
  Scenario: Student can borrow equipment exactly 5 days in advance
    When I borrow 1 "Projector" from 5 days from now to 6 days from now
    Then I should see "Equipment booking submitted"

  Scenario: Student cannot borrow equipment less than 5 days in advance
    When I attempt to borrow 1 "Projector" from 4 days from now to 5 days from now
    Then I should see "Equipment must be booked at least 5 days in advance"

  Scenario: Equipment borrow form blocks dates before the lead-time minimum
    When I visit the equipment borrow page for "Projector"
    Then the equipment start date input should have a minimum date 5 days from now
    And the equipment end date input should have a minimum date 5 days from now

  # Constraint: Equipment can be booked for at most 7 days
  Scenario: Student can borrow equipment for up to 7 days
    When I borrow 1 "Projector" from 5 days from now to 12 days from now
    Then I should see "Equipment booking submitted"

  Scenario: Student cannot borrow equipment for more than 7 days
    When I attempt to borrow 1 "Projector" from 5 days from now to 13 days from now
    Then I should see "Equipment booking duration cannot exceed 7 days"
