require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Autogui::Input
include Autogui::Logging

describe "FormAbout" do

  before(:all) do
    @application = Myapp.new
    keystroke(VK_RETURN) if @application.dialog_login(:timeout => 5)
  end

  after(:all) do
    @application.close(:wait_for_close => true) if @application.running?
    @application.should_not be_running
  end

  before(:each) do
    @application.dialog_about.should be_nil
    @application.set_focus
    keystroke(VK_MENU, VK_H, VK_A) 
    @dialog_about = @application.dialog_about
    @dialog_about.should_not be_nil
    @dialog_about.is_window?.should == true
  end

  after(:each) do
    @dialog_about.close if @dialog_about.is_window?
    @dialog_about.is_window?.should == false
  end

  it "should open with the hotkey combination VK_MENU, VK_H, VK_A" do
    @dialog_about.is_window?.should == true
  end

  it "should close by hitting return" do
    @dialog_about.set_focus
    keystroke(VK_RETURN) 
    @application.dialog_about.should be_nil
  end

  it "should have the title 'About MyApp'" do
    @dialog_about.title.should == "About MyApp"
  end

  it "should have an 'OK' button" do
    button = @dialog_about.children.find {|w| w.window_class == 'TButton'}
    button.should_not be_nil
    button.text.should match(/^OK$/)
  end

end
