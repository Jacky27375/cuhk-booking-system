Feature: SendGrid Email Notifications (External API)
  As a student society member
  I want to receive email notifications about my bookings
  So that I am informed when my booking is approved or rejected

  Background:
    Given the following users exist:
      | email                        | password  | role           |
      | student@link.cuhk.edu.hk     | password1 | society_member |
      | staff@link.cuhk.edu.hk       | password1 | staff          |
    And the following venues exist:
      | name     | department      |
      | Room 201 | Science Faculty |
    And "student@link.cuhk.edu.hk" has a pending booking for "Room 201" on "2026-04-20"

  Scenario: Approved booking triggers email via SendGrid
    Given I am logged in as "staff@link.cuhk.edu.hk"
    When I approve the booking for "Room 201" on "2026-04-20"
    Then the booking status should be "Approved"
    And an email notification should be sent to "student@link.cuhk.edu.hk"
    And the email subject should contain "Booking Approved"

  Scenario: Rejected booking triggers email via SendGrid
    Given I am logged in as "staff@link.cuhk.edu.hk"
    When I reject the booking for "Room 201" on "2026-04-20" with reason "Room under renovation"
    Then the booking status should be "Rejected"
    And an email notification should be sent to "student@link.cuhk.edu.hk"
    And the email subject should contain "Booking Rejected"
    And the email body should include "Room under renovation"

  Scenario: Email includes booking details
    Given I am logged in as "staff@link.cuhk.edu.hk"
    When I approve the booking for "Room 201" on "2026-04-20"
    Then an email notification should be sent to "student@link.cuhk.edu.hk"
    And the email body should include "Room 201"
