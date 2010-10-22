@calculator
Feature: Automating a GUI application

  As a developer, I want to run automated tests on GUI applications
  so that my specifications are testable in a repeatable manner.

  Background: A running GUI application
    Given A GUI application named calculator

  Scenario: Simple calculation
    When I type in "2+2="
    Then the edit window text should match /4/
