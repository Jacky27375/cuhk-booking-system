Feature: Booking Approval Workflow
  As a department staff member
  I want to approve or reject booking requests
  So that I can manage my department's resources

  Background:
    Given the following users exist:
      | email                 | password  | role    |
      | student@link.cuhk.edu.hk   | Password1! | student |
      | staff@link.cuhk.edu.hk | Password1! | staff   |
    And the following venues exist:
      | name     | department      |
      | Room 101 | Science Faculty |
    And "student@link.cuhk.edu.hk" has a pending booking for "Room 101" on a date 5 days in the future

  Scenario: Staff sees pending booking requests
    Given I am logged in as "staff@link.cuhk.edu.hk"
    When I visit the approval dashboard
    Then I should see the pending booking for "Room 101"
    And I should see status "Pending"

  Scenario: Staff approves a booking
    Given I am logged in as "staff@link.cuhk.edu.hk"
    When I approve the booking for "Room 101" on a date 5 days in the future
    Then the booking status should be "Approved"
    And "student@link.cuhk.edu.hk" should receive a confirmation email

  Scenario: Two-step tenant requires two approvals before final approval
    Given tenant "Science Faculty" uses two-step approval
    And I am logged in as "staff@link.cuhk.edu.hk"
    When I approve the booking for "Room 101" on a date 5 days in the future
    Then the booking status should be "Under review"
    When I approve the booking for "Room 101" on a date 5 days in the future
    Then the booking status should be "Approved"

  Scenario: Staff cannot manage bookings from another department
    Given I am logged in as "staff@link.cuhk.edu.hk"
    And there is a pending booking for "LT1" which belongs to "Arts Faculty"
    When I visit the approval dashboard
    Then I should not see the booking for "LT1"

  Scenario: Staff cannot approve another department booking via direct request
    Given I am logged in as "staff@link.cuhk.edu.hk"
    And there is a pending booking for "LT1" which belongs to "Arts Faculty"
    When I attempt to approve the booking for "LT1" on a date 5 days in the future directly
    Then the booking for "LT1" on a date 5 days in the future should remain "Pending"
    And I should see "You are not authorized to access this booking."

  Scenario: Society member cannot access approval dashboard
    Given I am logged in as "student@link.cuhk.edu.hk"
    When I visit the approval dashboard
    Then I should see "You are not authorized to perform this action."
    And I should not be on the approval dashboard page

  Scenario: Society member can cancel own pending booking
    Given I am logged in as "student@link.cuhk.edu.hk"
    When I visit my bookings page
    And I click "Cancel Booking"
    Then the booking for "Room 101" on a date 5 days in the future should remain "Cancelled"

  Scenario: Pending booking is automatically rejected after its booking date passes
    Given I am logged in as "staff@link.cuhk.edu.hk"
    And there is a venue "Expired Room"
    And "student@link.cuhk.edu.hk" has a pending booking for "Expired Room" 1 days in the past
    When I run the expired booking rejection job
    Then the booking status should be "Rejected"
    And the booking rejection reason should be "Booking date has passed"
    When I visit the approval dashboard
    Then I should not see the pending booking for "Expired Room"

  @javascript
  Scenario: Student is notified in real-time when booking is approved
    Given I am logged in as "student@link.cuhk.edu.hk"
    And I am viewing "My Bookings"
    When the staff approves my booking for "Room 101"
    Then I should see the status update to "Approved" without refreshing the page

  @javascript
  Scenario: Student sees cancel action removed when booking is rejected in real-time
    Given I am logged in as "student@link.cuhk.edu.hk"
    And I am viewing "My Bookings"
    When the staff rejects my booking for "Room 101" with reason "No staff available"
    Then I should see the booking status update to "Rejected" and remove the "Cancel Booking" action without refreshing
