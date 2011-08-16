History
=======
Most recent changes are at the top

Changes
-------

### 0.5.0 - 08/16/2011 ###

* Ruby 1.9.2.p290 compatible

### 0.4.3 - 03/17/2011 ###

* Add test coverage for Autogui::Input using Notepad.exe
* Fix Autogui::Input broken quote handling (jondot)

### 0.4.2 - 02/07/2011 ###

* Add logger.trunc attribute to control log truncation, defaults to true

### 0.4.1 - 02/03/2011 ###

* Window.wait_for_close yields if a block is given allowing callbacks during
  long running waits in order to check for error message dialogs, etc.
* Lock down win32 gem dependencies to known working versions
* Add input support for shift numeric row
* Add input support for VK_OEM_1 through VK_OEM_7

### 0.4.0 - 11/22/2010 ###

* Internal specs, features and all examples should run out-of-the-box on both Cygwin and MingW installs
* EnumerateDesktopWindows now accepts an optional timeout allowing the "find"
  method to continue enumerating windows until the timeout is reached
* Added static logging constants to Autogui::Logging

### 0.3.0 - 11/08/2010 ###

* Added Log4R logging
* Window.set_focus works first call in IRB

### 0.2.1 - 11/05/2010 ###

* Added missing "require 'timeout'", fixes issue #1
* Replaced missing '@calculator' tag required to close down the calculator
  after running cucumber features

### 0.2.0 - 11/04/2010 ###

* Initial release
