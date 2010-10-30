require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Autogui::Input

describe "FormMain" do
  before(:all) do
    @application = Quicknote.new
    # debug
#     puts "application:"
#     puts @application.inspect
#     puts "application.combined_text:"
#     puts @application.combined_text
  end
  before(:each) do
    @application = Quicknote.new unless @application.running?
    @application.should be_running

    # arubu helpers
    FileUtils.rm_rf(current_dir)
  end
  after(:all) do
    @application.file_exit if @application.running?
    # still running? force it to close
    @application.close(:wait_for_close => true)  if @application.running?
    @application.should_not be_running
  end

  describe "after startup" do
    it "should have the title 'QuickNote - untitled.txt'" do
      @application.main_window.title.should == "QuickNote - untitled.txt"
    end
    it "should have no text" do
      @application.edit_window.text.should == '' 
    end
  end

  describe "editing text" do
    before(:each) do
      @application.set_focus
    end
    after(:each) do
      @application.file_new(:save => false)
    end

    it "should add the '+' modified flag to the title" do
      @application.main_window.title.should == "QuickNote - untitled.txt"
      type_in("hello world")
      @application.main_window.title.should == "QuickNote - +untitled.txt"
    end
    it "should change the text" do
      @application.edit_window.text.should == '' 
      type_in("hello world")
      @application.edit_window.text.should == 'hello world' 
    end
  end

  describe "file open" do
    before(:all) do
      @filename = "input_file.txt"
      @file_contents = create_file(@filename, "the quick brown fox")
      @application.set_focus
    end
    before(:each) do
      @application.set_focus
    end
    after(:each) do
      keystroke(VK_ESCAPE) if @application.file_open_dialog 
    end

    it "should prompt and save with modified text" do
      pending "file save"
    end
    it "should not prompt to save with unmodified text" do
      @application.main_window.title.should_not match(/\+/)
      keystroke(VK_MENU, VK_F, VK_O) 
      @application.message_dialog_confirm.should be_nil
    end

    describe "succeeding" do 
      before(:all) do
        @application.main_window.title.should == "QuickNote - untitled.txt"
        @application.file_open(fullpath(@filename), :save => false)
      end

      it "should change the title" do
        @application.main_window.title.should == "QuickNote - #{fullpath(@filename)}"
      end
      it "should load the text" do
        @application.edit_window.text.should == 'the quick brown fox' 
      end
    end

    describe "failing" do 
      before(:all) do
        @application.file_new(:save => false)
        @application.set_focus
        type_in("foobar")
        @application.file_open(fullpath("a_bogus_filename.txt"), :save => false)
        @application.error_dialog.should_not be_nil
      end
      after(:all) do
        if @application.error_dialog
          @application.error_dialog.set_focus
          keystroke(VK_ESCAPE) 
        end
      end

      it "should show an error dialog with message 'Cannot open file'" do
        @application.error_dialog.combined_text.should match(/Cannot open file/)
      end
      it "should keep existing text" do
        @application.edit_window.text.should == 'foobar' 
      end
    end
  end

  describe "file new (VK_MENU, VK_F, VK_N)" do
    before(:each) do
      @application.set_focus
    end
    after(:all) do
      @application.file_new(:save => false)
    end

    it "should prompt and save modified text" do
      pending
    end
    it "should not prompt to save with unmodified text" do
      pending
    end
    it "should change the title" do
      pending "file_open"
    end
    it "should remove the '+' modified flag from the title" do
      type_in("hello world")
      @application.main_window.title.should == "QuickNote - +untitled.txt"
      @application.file_new(:save => false)
      @application.main_window.title.should == "QuickNote - untitled.txt"
    end
    it "should clear the existing text" do
      type_in("hello world")
      @application.edit_window.text.should == 'hello world' 
      @application.file_new(:save => false)
      @application.edit_window.text.should == '' 
    end
  end
  
  describe "file save" do
    it "should do nothing unless modified text" do
      pending
    end
    it "should remove the '+' modified flag from the title" do
      pending
    end
    it "should save the text" do
      pending
    end
  end

  describe "file save as" do
    it "should prompt for filename" do
      pending
    end
    it "should remove the '+' modified flag from the title" do
      pending
    end
    it "should change the title" do
      pending
    end
    it "should save the text" do
      pending
    end
  end

  describe "file exit (VK_MENU, VK_F, VK_X)" do
    it "should prompt and save with modified text" do
      pending
    end
    it "should not prompt to save with unmodified text" do
      @application.set_focus
      keystroke(VK_MENU, VK_F, VK_X) 
      @application.main_window.is_window?.should == false
      @application.should_not be_running
    end
  end

end
