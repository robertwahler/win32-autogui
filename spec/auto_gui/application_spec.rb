require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/calculator')

include AutoGui::Input

describe AutoGui::Application do

  describe "driving calculator.exe" do

    before(:all) do
      @calculator = Calculator.new
    end

    after(:all) do
      @calculator.close(:wait_for_close => true) if @calculator.running?
      @calculator.should_not be_running
    end

    it "should be running when initialized" do
      @calculator.should be_running
    end

    it "should have the title 'Calculator'" do
      @calculator.main_window.title.should == 'Calculator'
    end

    it "should calculate '2+2=4'" do
      @calculator.keystroke(VK_2, VK_ADD, VK_2, VK_RETURN) 
      @calculator.edit_window.text.strip.should == "4."
    end

  end
end
