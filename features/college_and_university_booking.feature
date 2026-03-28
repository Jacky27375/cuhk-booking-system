Feature: College and University resource booking and approval isolation
  As a SaaS platform for CUHK
  I want to isolate college resources to their own students and staff
  While allowing university-wide resources to be booked by anyone

  Background:
    Given the following tenants exist:
      | name               | level      |
      | University         | university |
      | Shaw College       | college    |
      | New Asia College   | college    |
    And the following venues exist:
      | name               | tenant           | department |
      | Music Room G04     | University       | MUS        |
      | Lecture Theatre    | Shaw College     | ADM        |
      | Yali Lounge        | New Asia College | ADM        |

  Scenario: Student can book own college and university venues, but not others
    Given I am logged in as a "student" of "Shaw College"
    When I view the bookable venues list
    Then I should see "Lecture Theatre"
    And I should see "Music Room G04"
    But I should not see "Yali Lounge"

  Scenario: College Staff can only manage and approve their own college venues
    Given I am logged in as a "staff" of "Shaw College"
    When I view the approval dashboard
    Then I can approve bookings for "Lecture Theatre"
    But I cannot access bookings for "Music Room G04"
    And I cannot access bookings for "Yali Lounge"

  Scenario: University Staff can only manage university venues
    Given I am logged in as a "staff" of "University"
    When I view the approval dashboard
    Then I can approve bookings for "Music Room G04"
    But I cannot access bookings for "Lecture Theatre"