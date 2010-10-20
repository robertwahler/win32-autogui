require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/calculator')

include AutoGui::Input

describe AutoGui::Application do

  describe "driving calculator.exe" do

    before do
      @calculator = Calculator.new
    end

    after do
      @calculator.close(:wait_for_close => true) if @calculator.running?
      @calculator.should_not be_running
    end

    it "should be running when initialized" do
      @calculator.should be_running
    end

    it "should calculate '2+2=4'" do
      @calculator.keystroke(VK_2, VK_ADD, VK_2, VK_RETURN) 
    end

  end
end
