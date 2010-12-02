require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Autogui::Input
include Autogui::Logging

logger.level = Autogui::Logging::DEBUG

describe "FormMain" do
  before(:all) do
    @application = Myapp.new
    keystroke(VK_RETURN) if @application.dialog_login(:timeout => 5)
    #logger.debug "FormMain before(:all)" 
    #logger.debug "application:\n#{@application.inspect}\n" 
    #logger.debug "application.combined_text:\n #{@application.combined_text}\n" 
  end
  before(:each) do
    @application = Myapp.new unless @application.running?
    @application.should be_running
    @application.set_focus
  end
  after(:all) do
    if @application.running?
      @application.file_exit 
      # still running? force it to close
      @application.close(:wait_for_close => true)
      @application.should_not be_running
    end
  end
  after(:each) do
    if @application.running?
      keystroke(VK_N) if @application.dialog_confirm || @application.dialog_overwrite_confirm
      keystroke(VK_ESCAPE) if @application.dialog_error
    end
  end

  describe "after startup" do
    it "should have the title 'Myapp" do
      @application.main_window.title.should match(/MyApp/)
    end
  end

  describe "file exit (VK_MENU, VK_F, VK_X)" do
    it "should exit without prompts" do
      keystroke(VK_MENU, VK_F, VK_X) 
      @application.dialog_confirm.should be_nil
      @application.main_window.is_window?.should == false
      @application.should_not be_running
    end
  end

end
