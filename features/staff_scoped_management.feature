Feature: Staff scoped management and booking lead time
  As a staff member and student
  I want management forms and booking dates to be limited by college scope and lead time
  So that invalid choices are blocked up front

  Background:
    Given the following college tenants exist:
      | name              |
      | New Asia College  |
      | University        |
    And a root staff account "staff_root_newasia@link.cuhk.edu.hk" exists for "New Asia College"
    And a regular staff "staff_newasia@link.cuhk.edu.hk" exists for "New Asia College"
    And a student "member@link.cuhk.edu.hk" exists for "New Asia College"
    And there is a venue "Lecture Hall A"

  Scenario: Staff venue form is limited to their college
    Given I am logged in as "staff_newasia@link.cuhk.edu.hk" with password "Password1!"
    When I visit the venues page
    And I click "New Venue"
    Then the venue department dropdown should include only:
      | New Asia College |
    And the venue department dropdown should not include "University"

  Scenario: Root staff is directed to request new venues
    Given I am logged in as "staff_root_newasia@link.cuhk.edu.hk" with password "Password1!"
    When I visit the venues page
    Then I should see link "Request New Venue"
    When I visit the new venue page
    Then I should see "Root staff must submit a venue request to add new venues."
    And I should see "New Venue Request"

  Scenario: Booking date picker blocks dates inside the lead-time window
    Given I am logged in as "member@link.cuhk.edu.hk" with password "Password1!"
    When I open the booking page for "Lecture Hall A" on a date 5 days in the future
    Then the booking date input should have a minimum date 5 days in the future

  Scenario: Admin can choose from all colleges and University for new equipment
    Given the following college tenants exist:
      | name                |
      | University          |
      | Chung Chi College   |
      | New Asia College    |
      | United College      |
      | Shaw College        |
      | Morningside College |
      | S.H. Ho College     |
      | CW Chu College      |
      | Wu Yee Sun College  |
      | Lee Woo Sing College |
    And there is a user "admin@link.cuhk.edu.hk" with role "admin"
    And I am logged in as "admin@link.cuhk.edu.hk"
    When I visit the new equipment page
    Then the equipment tenant dropdown should include only:
      | University |
      | Chung Chi College |
      | New Asia College |
      | United College |
      | Shaw College |
      | Morningside College |
      | S.H. Ho College |
      | CW Chu College |
      | Wu Yee Sun College |
      | Lee Woo Sing College |
