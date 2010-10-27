@application
Feature: Hotkeys

  As a user, I want operate QuickNote using hotkeys
  so that I can don't have to grab the mouse

  Scenario: Exiting the application
      When I enter the keystrokes "VK_MENU, VK_H, VK_A" 
#     When I type in "2+2="
#     Then the edit window text should match /4/

  Scenario: Opening the about dialog
      When I enter the keystrokes "VK_MENU, VK_H, VK_A" 
      Then I should see the about dialog
