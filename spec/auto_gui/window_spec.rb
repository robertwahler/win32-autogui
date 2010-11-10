require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Autogui::Input

describe Autogui::EnumerateDesktopWindows do

  describe "finding dialogs" do
    before(:all) do
      @calculator = Calculator.new
    end
    before(:each) do
      @calculator.should be_running
      @calculator.set_focus
    end
    after(:all) do
      @calculator.close(:wait_for_close => true) if @calculator.running?
      @calculator.should_not be_running
    end

    describe "with the default timeout of 0" do
      it "should find a valid dialog" do
        keystroke(VK_MENU, VK_H, VK_A) 
        dialog_about = Autogui::EnumerateDesktopWindows.new.find do |w| 
          w.title.match(/About Calculator/) && (w.pid == @calculator.pid)
        end
        dialog_about.should_not be_nil
        dialog_about.close
      end
      it "should not find an invalid dialog" do
        dialog_bogus = Autogui::EnumerateDesktopWindows.new.find do |w| 
          w.title.match(/Bogus Window that does not exist/) && (w.pid == @calculator.pid)
        end
        dialog_bogus.should be_nil
      end
    end

    describe "with the timeout of 3 seconds" do
      it "should find a valid dialog in less than 3 seconds" do
        keystroke(VK_MENU, VK_H, VK_A) 
        seconds = 3
        dialog_about = nil
        lambda {timeout(seconds) do
          dialog_about = Autogui::EnumerateDesktopWindows.new(:timeout => seconds).find do |w| 
            w.title.match(/About Calculator/) && (w.pid == @calculator.pid)
          end
        end}.should_not raise_error
        dialog_about.should_not be_nil
        dialog_about.close
      end
      it "should look for an invalid dialog for 3 seconds" do
        seconds = 3
        dialog_bogus = nil
        lambda {timeout(seconds) do
          dialog_bogus = Autogui::EnumerateDesktopWindows.new(:timeout => seconds).find do |w| 
            w.title.match(/Bogus Window that does not exist/) && (w.pid == @calculator.pid)
          end
        end}.should raise_error
        dialog_bogus.should be_nil
      end
    end

  end
end
