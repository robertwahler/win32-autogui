require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Autogui::Input

describe "FormMain" do
  before(:all) do
    @debug = false
    @verbose = true
    @application = Myapp.new
    FileUtils.rm_rf(current_dir)
    puts "FormMain before(:all)" if @debug
    puts "application:\n#{@application.inspect}\n" if @debug && @verbose
    puts "application.combined_text:\n #{@application.combined_text}\n" if @debug && @verbose
  end
  before(:each) do
    @application = Myapp.new unless @application.running?
    @application.should be_running
    @application.set_focus
    puts "FormMain before(:each)" if @debug
  end
  after(:all) do
    if @application.running?
      @application.file_exit 
      # still running? force it to close
      @application.close(:wait_for_close => true)
      @application.should_not be_running
    end
    puts "FormMain after(:all)" if @debug
  end
  after(:each) do
    if @application.running?
      keystroke(VK_N) if @application.message_dialog_confirm || @application.dialog_overwrite_confirm
      keystroke(VK_ESCAPE) if @application.error_dialog
    end
    puts "FormMain after(:each)" if @debug
  end

  describe "after startup" do
    it "should have the title 'Myapp" do
      @application.main_window.title.should == "Myapp"
    end
    it "should have no text" do
      @application.edit_window.text.should == '' 
    end
  end

  describe "file exit (VK_MENU, VK_F, VK_X)" do
    it "should prompt and save with modified text" do
      type_in("anything")
      keystroke(VK_MENU, VK_F, VK_X) 
      @application.message_dialog_confirm.should_not be_nil
      @application.main_window.is_window?.should == true
      @application.should be_running
    end
    it "should not prompt to save with unmodified text" do
      keystroke(VK_MENU, VK_F, VK_X) 
      @application.message_dialog_confirm.should be_nil
      @application.main_window.is_window?.should == false
      @application.should_not be_running
    end
  end

end
