require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Autogui::Input

describe "FormAbout" do

  before(:all) do
    @application = Quicknote.new
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

  it "should have the title 'About QuickNote'" do
    @dialog_about.title.should == "About QuickNote"
  end

  it "should have an 'Ok' button" do
    puts @dialog_about.inspect
    pending
  end

# TODO: static painted text?  For messagedialogs, set the title to unique text so they can be detected
#   it "should have a copyright notice" do
#     puts @dialog_about.inspect
#     @dialog_about.combined_text.should match(/Copyright .* GearheadForHire.com, LLC/)
#   end

end
