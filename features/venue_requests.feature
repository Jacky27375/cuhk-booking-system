Feature: Venue Request Workflow
  As a staff member
  I want to request new venues for my college
  So that an admin can approve and create them

  Background:
    Given the following college tenants exist:
      | name              |
      | Chung Chi College |
    And the following users exist:
      | email                   | password   | role  |
      | admin@link.cuhk.edu.hk  | Password1! | admin |
    And a root staff account "staff@link.cuhk.edu.hk" exists for "Chung Chi College"

  Scenario: Staff can submit a venue request
    Given I am logged in as "staff@link.cuhk.edu.hk" with password "Password1!"
    When I visit the new venue request page
    And I fill in "Venue Name" with "New Seminar Room"
    And I fill in "Description" with "A seminar room for 30 people"
    And I press "Submit Request"
    Then I should see "Venue request submitted successfully"
    And I should see "New Seminar Room"
    And I should see "Pending"

  Scenario: Admin can approve a venue request
    Given "staff@link.cuhk.edu.hk" has submitted a venue request for "Lab 201"
    And I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I visit the venue requests page
    Then I should see "Lab 201"
    When I press "Approve"
    Then I should see "Venue request approved"
    And a venue named "Lab 201" should exist for "Chung Chi College"

  Scenario: Admin can reject a venue request
    Given "staff@link.cuhk.edu.hk" has submitted a venue request for "Duplicate Room"
    And I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I visit the venue requests page
    And I fill in "Rejection reason" with "Not needed"
    And I press "Reject"
    Then I should see "Venue request rejected"
    And I should see "Reason: Not needed"

  Scenario: Admin panel links directly to pending venue-request review
    Given "staff@link.cuhk.edu.hk" has submitted a venue request for "Lab 301"
    And I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I visit the admin panel
    Then I should see "Review Pending Requests"
    And I should see "1 pending request(s) need review"

  Scenario: Student cannot access venue requests
    Given a student "student@link.cuhk.edu.hk" exists for "Chung Chi College"
    And I am logged in as "student@link.cuhk.edu.hk" with password "Password1!"
    When I visit the venue requests page
    Then I should see "Dashboard"
