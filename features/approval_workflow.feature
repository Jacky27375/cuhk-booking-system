Feature: Booking Approval Workflow
  As a department staff member
  I want to approve or reject booking requests
  So that I can manage my department's resources

  Background:
    Given the following users exist:
      | email                 | password  | role    |
      | student@link.cuhk.edu.hk   | password1 | student |
      | staff@link.cuhk.edu.hk | password1 | staff   |
    And the following venues exist:
      | name     | department      |
      | Room 101 | Science Faculty |
    And "student@link.cuhk.edu.hk" has a pending booking for "Room 101" on "2026-04-20"

  Scenario: Staff sees pending booking requests
    Given I am logged in as "staff@link.cuhk.edu.hk"
    When I visit the approval dashboard
    Then I should see the pending booking for "Room 101"
    And I should see status "Pending"

  Scenario: Staff approves a booking
    Given I am logged in as "staff@link.cuhk.edu.hk"
    When I approve the booking for "Room 101" on "2026-04-20"
    Then the booking status should be "Approved"
    And "student@link.cuhk.edu.hk" should receive a confirmation email

  Scenario: Staff rejects a booking with a reason
    Given I am logged in as "staff@link.cuhk.edu.hk"
    When I reject the booking for "Room 101" on "2026-04-20" with reason "Maintenance scheduled"
    Then the booking status should be "Rejected"
    And "student@link.cuhk.edu.hk" should receive a rejection email with "Maintenance scheduled"

  Scenario: Staff cannot manage bookings from another department
    Given I am logged in as "staff@link.cuhk.edu.hk"
    And there is a pending booking for "LT1" which belongs to "Arts Faculty"
    When I visit the approval dashboard
    Then I should not see the booking for "LT1"

  Scenario: Student is notified in real-time when booking is approved
    Given I am logged in as "student@link.cuhk.edu.hk"
    And I am viewing "My Bookings"
    When the staff approves my booking for "Room 101"
    Then I should see the status update to "Approved" without refreshing the page
