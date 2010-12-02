Win32-Autogui
=============

A Win32 GUI testing framework packaged as a [RubyGem](http://rubygems.org/).


Overview
--------
Win32-autogui provides a framework to enable GUI application testing 
with Ruby.  This facilitates integration testing of Windows binaries using 
Ruby based tools like [RSpec](http://github.com/dchelimsky/rspec) 
and [Cucumber](http://github.com/aslakhellesoy/cucumber).  Examples of 
using both these tools are provided with this gem.


Quick Start Options
-------------------
See [examples/skeleton/README.markdown](examples/skeleton/README.markdown)
for a template of the file structure needed for jump-starting GUI testing
with the Win32-autogui RubyGem.

Read our introduction blog posting here: <http://www.gearheadforhire.com/articles/ruby/win32-autogui/using-ruby-to-drive-windows-applications>

Run Win32-autogui's internal specs and example programs.

    gem install win32-autogui
    gem install rake bundler win32console cucumber 
    gem install rspec -v 1.3.1

    cd C:\Ruby187\lib\ruby\gems\1.8\gems\win32-autogui-0.4.0
    bundle install

    # run the calculator specs and features
    rake

    # run the example quicknote specs
    cd examples\quicknote
    rake


Example Usage: Driving Calc.exe
-------------------------------

Using [RSpec](http://github.com/dchelimsky/rspec) to test drive the stock 
Window's calculator application.  This example is used as Win32-autogui's 
internal spec. See [spec/auto_gui/application_spec.rb](spec/auto_gui/application_spec.rb).  

A more complete example of testing a Window's Delphi program is presented with 
source and binaries in [examples/quicknote/](examples/quicknote/).

### Wrap the application to be tested ###
The first step is to subclass Win32-autogui's application class.

    require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

    class Calculator < Autogui::Application

      # initialize with the binary name 'calc' and the window title
      # 'Calculator' used along with the application pid to find the 
      # main application window
      def initialize(options = {})
        defaults = {
                     :name => "calc",
                     :title => "Calculator",
                     :logger_level => Autogui::Logging::DEBUG
                   }
        super defaults.merge(options)
      end

      # the calculator's results window 
      def edit_window
        main_window.children.find {|w| w.window_class == 'Edit'}
      end

      # About dialog, hotkey (VK_MENU, VK_H, VK_A)
      def dialog_about(options = {})
        Autogui::EnumerateDesktopWindows.new(options).find do |w| 
          w.title.match(/About Calculator/) && (w.pid == pid)
        end
      end
      
      # the 'CE' button
      def clear_entry
        set_focus
        keystroke(VK_DELETE)
      end

    end


### Write specs ###
The following RSpec code describes driving the Windows calculator for testing. 
Multiple instances running simultaneously are supported.  See "should control
focus with set_focus."


    require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

    include Autogui::Input
    include Autogui::Logging

    describe Autogui::Application do

      describe "driving calc.exe" do

        before(:all) do
          @calculator = Calculator.new
          @calculator.set_focus
        end

        after(:all) do
          @calculator.close(:wait_for_close => true) if @calculator.running?
          @calculator.should_not be_running
        end

        it "should start when initialized" do
          @calculator.should be_running
        end

        it "should die when sending the kill signal" do
          killme = Calculator.new
          killme.should be_running
          killme.kill
          killme.should_not be_running
        end

        it "should have the title 'Calculator' that matches the main_window title" do
          @calculator.main_window.title.should == 'Calculator'
          @calculator.main_window.title.should == @calculator.title
        end

        it "should have an inspect method showing child window information" do
          @calculator.inspect.should match(/children=</)
        end

        it "should raise an error if setting focus and the application title is incorrect" do
          goodcalc = Calculator.new :title => "Calculator"
          lambda { goodcalc.set_focus }.should_not raise_error
          goodcalc.close

          badcalc = Calculator.new :title => "BaDTitle"
          lambda {
            begin
              badcalc.setfocus
            ensure
              badcalc.kill
            end
          }.should raise_error
        end

        it "should control the focus with 'set_focus'" do
          @calculator.set_focus
          keystroke(VK_9)
          @calculator.edit_window.text.strip.should == "9."
          
          calculator2 = Calculator.new
          calculator2.pid.should_not == @calculator.pid
          calculator2.set_focus
          keystroke(VK_1, VK_0) 
          calculator2.edit_window.text.strip.should == "10."

          @calculator.set_focus
          @calculator.edit_window.text.strip.should == "9."

          calculator2.close(:wait_for_close => true)
        end

        it "should open and close the 'About Calculator' dialog via (VK_MENU, VK_H, VK_A)" do
          @calculator.set_focus
          dialog_about = @calculator.dialog_about
          dialog_about.should be_nil
          keystroke(VK_MENU, VK_H, VK_A) 
          dialog_about = @calculator.dialog_about
          dialog_about.title.should == "About Calculator"
          dialog_about.combined_text.should match(/Microsoft . Calculator/)
          dialog_about.close
          @calculator.dialog_about.should be_nil
        end

        describe "calculations" do
          before(:each) do
            @calculator.clear_entry
          end

          it "should calculate '2+2=4' using the keystroke method" do
            @calculator.set_focus
            keystroke(VK_2, VK_ADD, VK_2, VK_RETURN) 
            @calculator.edit_window.text.strip.should == "4."
          end

          it "should calculate '2+12=14' using the type_in method" do
            @calculator.set_focus
            type_in("2+12=")
            @calculator.edit_window.text.strip.should == "14."
          end
        end

        describe "clipboard" do
          before(:each) do
            @calculator.clear_entry
            @calculator.clipboard.text = ""
            @calculator.clipboard.text.should == ""
          end
          
          describe "copy (VK_CONTROL, VK_C)" do
            it "should copy the edit window" do
              @calculator.set_focus
              type_in("3002")
              @calculator.edit_window.text.strip.should match(/3,?002\./)
              @calculator.edit_window.set_focus
              keystroke(VK_CONTROL, VK_C) 
              @calculator.clipboard.text.should == "3002"
            end
          end

          describe "paste (VK_CONTROL, VK_V)" do
            it "should paste into the edit window" do
              @calculator.edit_window.set_focus
              @calculator.clipboard.text = "12345"
              @calculator.edit_window.text.strip.should == "0."
              keystroke(VK_CONTROL, VK_V) 
              @calculator.edit_window.text.strip.should match(/12,?345\./)
            end
          end

        end

      end
    end


System Requirements
-------------------

Windows OS, version 2000 or higher 

Testing was done on the following Ruby platforms:

* ruby 1.8.7 (2008-08-11 patchlevel 72) [i386-cygwin]
* ruby 1.8.7 (2010-08-16 patchlevel 302) [i386-mingw32]


Dependencies
------------
Win32-autogui depends on the following RubyGems

* Windows-api <http://github.com/djberg96/win32-api>
* Windows-pr  <http://github.com/djberg96/windows-pr>
* Win32-process <http://github.com/djberg96/win32-process>
* Win32-clipboard <http://github.com/djberg96/win32-clipboard>
* Log4r for logging <http://log4r.rubyforge.org/>


Installation
------------
Win32-autogui is available on [RubyGems.org](http://rubygems.org/gems/win32-autogui)

    gem install win32-autogui


References and Alternative Libraries
------------------------------------

* Scripted GUI Testing with Ruby by Ian Dees <http://pragprog.com/titles/idgtr/scripted-gui-testing-with-ruby>
* RAA - win32-guitest <http://raa.ruby-lang.org/project/win32-guitest>
* Updated win32-guitest <http://rubyforge.org/projects/guitest>


Development
-----------
Win32-autogui development was jump-started by cloning [BasicGem](http://github.com/robertwahler/basic_gem).

### Dependencies ###

* Bundler for dependency management <http://github.com/carlhuda/bundler>
* RSpec for unit testing <http://github.com/dchelimsky/rspec>
* Cucumber for functional testing <http://github.com/aslakhellesoy/cucumber>
* Aruba for CLI testing <http://github.com/aslakhellesoy/aruba>
* YARD for documentation generation <http://github.com/lsegal/yard>
* Kramdown for documentation markup processing <https://github.com/gettalong/kramdown>

### Rake tasks ###

rake -T

    rake build         # Build win32-autogui-0.0.1.gem into the pkg directory
    rake doc:clean     # Remove generated documenation
    rake doc:generate  # Generate YARD Documentation
    rake features      # Run Cucumber features
    rake install       # Build and install win32-autogui-0.0.1.gem into system gems
    rake release       # Create tag v0.0.1 and build and push win32-autogui-0.0.1.gem to Rubygems
    rake spec          # Run specs
    rake test          # Run specs and features


### Autotesting with Watchr ###

[Watchr](http://github.com/mynyml/watchr) provides a flexible alternative to Autotest.  A
jump start script is provided in spec/watchr.rb.

#### Install watchr ###

    gem install watchr

#### Run watchr ###

    watchr spec/watchr.rb

outputs a menu

    Ctrl-\ for menu, Ctrl-C to quit

Watchr will now watch the files defined in 'spec/watchr.rb' and run RSpec or Cucumber, as appropriate.
The watchr script provides a simple menu.

Ctrl-\

    MENU: a = all , f = features  s = specs, l = last feature (none), q = quit


Copyright
---------

Copyright (c) 2010 GearheadForHire, LLC. See [LICENSE](LICENSE) for details.
