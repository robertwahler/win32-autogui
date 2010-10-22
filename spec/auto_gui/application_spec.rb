require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Autogui::Input

describe Autogui::Application do

  describe "driving calculator.exe" do

    before(:all) do
      @calculator = Calculator.new
    end

    after(:all) do
      @calculator.close(:wait_for_close => true) if @calculator.running?
      @calculator.should_not be_running
    end

    it "should start when initialized" do
      @calculator.should be_running
    end

    it "should have the title 'Calculator' that matches the main_window title" do
      @calculator.main_window.title.should == 'Calculator'
      @calculator.main_window.title.should == @calculator.title
    end

    it "should have an inspect method showing child window information" do
      @calculator.inspect.should match(/@children=@window_class: Edit/)
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

    it "should open and close the 'About Calculator' dialog" do
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

  end
end
