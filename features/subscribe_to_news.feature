@javascript
Feature: As a visitor
  In order to stay in the loop about the development of Visualizer
  I would like to be able to subscribe to a newsleter

  Background:
    Given I am on the landing page

  Scenario: Sign up with email
    And I fill in "Your Email" with "thomas@craftacademy.se"
    And I click on "Subscribe"
    Then I should see "Alright, we signed up: thomas@craftacademy.se Thank you! We'll be in touch"

  Scenario: Sign up with badly formatted email
    And I fill in "Your Email" with "thomascraftacademy.se"
    And I click on "Subscribe"
    Then I should see "An email address must contain a single @"