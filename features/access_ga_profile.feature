Feature: As a potential user
  In order to be able to access my Google Analytics profile
  I want to be able to perform an authorization using my Google account and see a list of my web resources


  Scenario: List my web resources
    Given I am on the landing page
    And I click on "CONNECT ACCOUNT"
    Then show me the page
