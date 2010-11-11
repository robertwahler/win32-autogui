require 'myapp'

include Autogui::Input
include Autogui::Logging

After('@application') do
  if @application && @application.running?
    @application.dialog_tips.close if @application.dialog_tips
    @application.dialog_wizard.close if @application.dialog_wizard
    begin
      @application.close(:wait_for_close => true) if @application.running?
    rescue
      @application.kill
      raise
    end
  end
end

Given /^the application is running$/ do 
  unless @application && @application.running?
    @application = Myapp.new
    @application.should be_running
  end
end

When /^I start the application with parameters "([^"]*)"$/ do |parameters|
  @application = Myapp.new  :parameters => parameters
  @application.should be_running
end

When /^I start the application$/ do
  data_folder = cygpath_to_windows_path(File.expand_path(current_dir))
  @application = Myapp.new  :parameters => "--nosplash  --data_folder:#{data_folder}"
  @application.should be_running
end

When /^I type in "([^"]*)"$/ do |string|
  @application.set_focus
  type_in(string)
end

# "the window text should match" allows regex in the partial_output, if
# you don't need regex, use "the output should contain" instead since
# that way, you don't have to escape regex characters that
# appear naturally in the output
Then /^the edit window text should match \/([^\/]*)\/$/ do |partial_output|
  @application.edit_window.text.should =~ /#{partial_output}/
end

Then /^the edit window text should contain exactly "([^"]*)"$/ do |exact_output|
  @application.edit_window.text.should == unescape(exact_output)
end

Then /^the edit window text should contain exactly:$/ do |exact_output|
  @application.edit_window.text.should == exact_output
end

