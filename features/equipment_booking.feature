Feature: Equipment Booking
  As a student
  I want to borrow equipment from a department
  So that I can use it for my society's activities

  Background:
    Given I am logged in as "student@cuhk.edu.hk"
    And the following equipment exists:
      | name          | department       | quantity |
      | Projector     | Science Faculty  | 3        |
      | Microphone    | Arts Faculty     | 5        |
      | Laptop        | Engineering Dept | 2        |

  Scenario: Student views available equipment
    When I visit the equipment page
    Then I should see "Projector"
    And I should see "available: 3"

  Scenario: Student successfully borrows available equipment
    When I borrow 1 "Projector" from "2026-04-20" to "2026-04-21"
    Then I should see "Equipment booking submitted"
    And the available count for "Projector" should show 2

  Scenario: Student cannot borrow more than available quantity
    When I borrow 5 "Laptop" from "2026-04-20" to "2026-04-21"
    Then I should see "Not enough units available"

  Scenario: Student returns equipment
    Given I have an approved loan of 1 "Projector" ending today
    When I mark the "Projector" as returned
    Then the available count for "Projector" should be restored
    And my booking should show status "Returned"