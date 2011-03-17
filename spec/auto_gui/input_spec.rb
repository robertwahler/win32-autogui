require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Autogui::Input

describe Autogui::Input do
  before(:each) do
    @application = Notepad.new
    @application.main_window.title.should == "Untitled - Notepad"
  end
  after(:each) do
    if @application.running?
      @application.file_exit
      # still running? force it to close
      @application.close(:wait_for_close => true)
      @application.should_not be_running
    end
  end

  describe "keystroke" do

    it "should input virtual keycodes" do
      @application.edit_window.text.should == ""
      keystroke(VK_A)
      @application.edit_window.text.should == 'a'
      keystroke(VK_SHIFT, VK_A)
      @application.edit_window.text.should == 'aA'
      keystroke(VK_BACK)
      keystroke(VK_BACK)
      @application.edit_window.text.should == ''
    end
  end

  describe "type_in" do

    it "should input a string one character at a time" do
      @application.edit_window.text.should == ""
      input_string = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      type_in(input_string)
      @application.edit_window.text.should == input_string
      input_string.should_not be_nil
      input_string.should_not == ""
    end

    it "should handle non-alphanumerics" do
      @application.edit_window.text.should == ""
      input_string = %( +=,.-_;:/?~[]{}$%^&*`)
      type_in(input_string)
      @application.edit_window.text.should == input_string
      input_string.should_not be_nil
      input_string.should_not == ""
    end

    it "should handle special charaters" do
      @application.edit_window.text.should == ""
      type_in("#\\")
      @application.edit_window.text.should == "#\\"
      type_in("\n()")
      @application.edit_window.text.should == "#\\\r\n()"
    end

    it "should handle quotes" do
      @application.edit_window.text.should == ""
      type_in(%('"))
      @application.edit_window.text.should == %('")
    end
  end

end
