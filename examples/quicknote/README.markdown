QuickNote README
================

QuickNote is a stripped down Notepad clone written in Delphi.  It is an example GUI executable with
source code for the Win32-autogui gem.  It is not fit for any other purpose.

QuickNote specs
---------------
install development dependencies

    gem install bundler
    bundle install

run specs

    bundle exec rake

Modifications to the load paths for use in a real world project
----------------------------------------------------------------
**NOTE:** _see examples/skeleton for a ready-to-go template._

spec/spec_helper.rb

    # use development version of win32/autogui
    # remove these lines in production code
    $LOAD_PATH.unshift File.expand_path('../../../../lib', __FILE__) unless
      $LOAD_PATH.include? File.expand_path('../../../../lib', __FILE__)

lib/quicknote.rb

    # use the development version of win32-autogui
    # Production code should simply require 'win32/autogui'
    require File.expand_path(File.dirname(__FILE__) + '/../../../lib/win32/autogui')


Copyright
---------

Copyright (c) 2010-2012 GearheadForHire, LLC. See [LICENSE](LICENSE) for details.
