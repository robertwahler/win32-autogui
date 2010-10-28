require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Autogui::Input

describe "FormMain" do

  before(:all) do
    @application = Quicknote.new
    
    # debug
    puts "application:"
    puts @application.inspect
    puts "application.combined_text:"
    puts @application.combined_text
  end

  before(:each) do
    @application = Quicknote.new unless @application.running?
    @application.should be_running
  end

  after(:all) do
    @application.close(:wait_for_close => true) if @application.running?
    @application.should_not be_running
  end

  it "should have the title 'QuickNote - untitled.txt" do
    @application.main_window.title.should == "QuickNote - untitled.txt"
  end

  it "should close with the hotkey combination VK_MENU, VK_F, VK_X" do
    @application.set_focus
    keystroke(VK_MENU, VK_F, VK_X) 
    @application.main_window.is_window?.should == false
    @application.should_not be_running
  end

end
