require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Autogui::Input

describe "FormMain" do
  before(:all) do
    @debug = false
    @verbose = true
    @application = Quicknote.new
    FileUtils.rm_rf(current_dir)
    puts "FormMain before(:all)" if @debug
    puts "application:\n#{@application.inspect}\n" if @debug && @verbose
    puts "application.combined_text:\n #{@application.combined_text}\n" if @debug && @verbose
  end
  before(:each) do
    @application = Quicknote.new unless @application.running?
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
      keystroke(VK_N) if @application.message_dialog_confirm
      keystroke(VK_ESCAPE) if @application.error_dialog
    end
    puts "FormMain after(:each)" if @debug
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
    after(:each) do
      @application.file_new(:save => false)
    end

    it "should add the '+' modified flag to the title" do
      @application.main_window.title.should == "QuickNote - untitled.txt"
      type_in("hello")
      @application.main_window.title.should == "QuickNote - +untitled.txt"
    end
    it "should change the text" do
      @application.edit_window.text.should == '' 
      type_in("hello")
      @application.edit_window.text.should == 'hello' 
    end
  end

  describe "file open (VK_MENU, VK_F, VK_O)" do
    before(:each) do
      @filename = "input_file.txt"
      @file_contents = create_file(@filename, "the quick brown fox")
      @application.file_new(:save => false)
    end
    after(:each) do
      keystroke(VK_N) if @application.message_dialog_confirm
      keystroke(VK_ESCAPE) if @application.file_open_dialog 
    end

    it "should prompt to save with modified text" do
      type_in("foobar")
      @application.main_window.title.should match(/\+/)
      keystroke(VK_MENU, VK_F, VK_O) 
      @application.message_dialog_confirm.should_not be_nil
    end
    it "should not prompt to save with unmodified text" do
      @application.main_window.title.should_not match(/\+/)
      keystroke(VK_MENU, VK_F, VK_O) 
      @application.message_dialog_confirm.should be_nil
    end

    describe "succeeding" do 
      it "should add the filename to the title" do
        @application.main_window.title.should == "QuickNote - untitled.txt"
        @application.file_open(fullpath(@filename), :save => false)
        @application.main_window.title.should == "QuickNote - #{fullpath(@filename)}"
      end
      it "should load the text" do
        @application.file_open(fullpath(@filename), :save => false)
        @application.edit_window.text.should == 'the quick brown fox' 
      end
    end

    describe "failing" do 
      it "should show an error dialog with message 'Cannot open file'" do
        type_in("foobar")
        @application.file_open(fullpath("a_bogus_filename.txt"), :save => false)
        @application.error_dialog.should_not be_nil
        @application.error_dialog.combined_text.should match(/Cannot open file/)
      end
      it "should keep existing text" do
        type_in("foobar")
        @application.file_open(fullpath("a_bogus_filename.txt"), :save => false)
        @application.error_dialog.should_not be_nil
        @application.edit_window.text.should == 'foobar' 
      end
    end
  end

  describe "file new (VK_MENU, VK_F, VK_N)" do
    after(:each) do
      #keystroke(VK_N) if @application.message_dialog_confirm
    end

    it "should prompt to save modified text" do
      type_in("hello")
      @application.main_window.title.should match(/\+/)
      keystroke(VK_MENU, VK_F, VK_N) 
      @application.message_dialog_confirm.should_not be_nil
    end
    it "should not prompt to save with unmodified text" do
      @application.file_new(:save => false)
      @application.main_window.title.should_not match(/\+/)
      keystroke(VK_MENU, VK_F, VK_N) 
      @application.message_dialog_confirm.should be_nil
    end
    it "should add the filename 'untitled.txt' to the title" do
      filename = "input_file.txt"
      file_contents = create_file(filename, "the quick brown fox")
      @application.file_open(filename, :save => false)
      @application.main_window.title.should match(/#{filename}/)
      @application.file_new(:save => false)
      @application.main_window.title.should == "QuickNote - untitled.txt"
    end
    it "should remove the '+' modified flag from the title" do
      type_in("hello")
      @application.main_window.title.should match(/\+/)
      @application.file_new(:save => false)
      @application.main_window.title.should_not match(/\+/)
    end
    it "should clear the existing text" do
      type_in("hello")
      @application.edit_window.text.should match(/hello/) 
      @application.file_new(:save => false)
      @application.edit_window.text.should == '' 
    end
  end
  
  describe "file save (VK_MENU, VK_F, VK_S)" do
    before(:each) do
      @filename = "input_file.txt"
      @file_contents = create_file(@filename, "original content")
      @application.file_open(fullpath(@filename), :save => false)
      @application.main_window.title.should == "QuickNote - #{fullpath(@filename)}"
      @application.edit_window.text.should == "original content" 
      @application.set_focus
    end

    it "should do nothing unless modified text" do
      append_to_file(@filename, "sneak in extra content that shouldn't be here")
      contents = get_file_content(@filename)
      contents.should match(/extra content/)
      @application.file_save
      contents.should match(/extra content/)
      @application.edit_window.text.should_not match(/extra content/)
    end

    describe "succeeding" do 
      it "should remove the '+' modified flag from the title" do
        type_in("anything")
        @application.main_window.title.should == "QuickNote - +#{fullpath(@filename)}"
        @application.file_save
        @application.main_window.title.should == "QuickNote - #{fullpath(@filename)}"
      end
      it "should save the text" do
        type_in("foobar")
        @application.edit_window.text.should == "foobar" + "original content"
        @application.file_save
        get_file_content(@filename).should == "foobar" + "original content"
      end
    end

    describe "failing" do 
      before(:each) do
        # set read-only to cause save failure
        in_current_dir do
          `attrib +R #{@filename}`
        end
      end
      after(:each) do
        # cleanup read-only file
        FileUtils.rm_rf(current_dir)
      end

      it "should show an error dialog with message 'Cannot create file'" do
        type_in("anything")
        @application.file_save
        @application.error_dialog.should_not be_nil
        @application.error_dialog.combined_text.should match(/Cannot create file/)
      end
      it "should keep the '+' modified flag on the title" do
        type_in("anything")
        @application.file_save
        @application.main_window.title.should == "QuickNote - +#{fullpath(@filename)}"
      end
      it "should keep existing text" do
        type_in("anything")
        @application.file_save
        @application.edit_window.text.should ==  "anything" + "original content"
      end
    end
  end

  describe "file save as (VK_MENU, VK_F, VK_A)" do
    it "should prompt for filename" do
      pending
    end
    it "should remove the '+' modified flag from the title" do
      pending
    end
    it "should add the filename to the title" do
      pending
    end
    it "should save the text" do
      pending
    end
  end

  describe "file exit (VK_MENU, VK_F, VK_X)" do
    it "should prompt and save with modified text" do
      type_in("anything")
      @application.set_focus
      keystroke(VK_MENU, VK_F, VK_X) 
      @application.message_dialog_confirm.should_not be_nil
      @application.main_window.is_window?.should == true
      @application.should be_running
    end
    it "should not prompt to save with unmodified text" do
      @application.set_focus
      keystroke(VK_MENU, VK_F, VK_X) 
      @application.message_dialog_confirm.should be_nil
      @application.main_window.is_window?.should == false
      @application.should_not be_running
    end
  end

end
