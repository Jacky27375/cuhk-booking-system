Feature: Role-based Access Control
  As a system administrator
  I want to restrict access based on user roles
  So that users can only access appropriate features

  Background:
    Given the following users exist:
      | email              | password   | role           |
      | admin@link.cuhk.edu.hk  | Password1! | admin          |
      | staff@link.cuhk.edu.hk  | Password1! | staff          |
      | member@link.cuhk.edu.hk | Password1! | society_member |

  Scenario: Admin can access admin panel
    Given I am logged in as "admin@link.cuhk.edu.hk" with password "Password1!"
    When I visit the admin panel
    Then I should see "Admin Panel"

  Scenario: Staff cannot access admin panel
    Given I am logged in as "staff@link.cuhk.edu.hk" with password "Password1!"
    When I visit the admin panel
    Then I should see "You are not authorized"

  Scenario: Society member cannot access admin panel
    Given I am logged in as "member@link.cuhk.edu.hk" with password "Password1!"
    When I visit the admin panel
    Then I should see "You are not authorized"
