require 'myapp'

include Autogui::Input

Before('@dry_run') do
  announce "### dry run ###"
  @dry_run = true
end
After('@application') do
   if @application && @application.running?
    @application.dialog_information.close if @application.dialog_information
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
    application_start
    @application.should be_running
  end
end

When /^I start the application with parameters "([^"]*)"$/ do |parameters|
  application_start(:parameters => parameters)
  @application.should be_running
end

When /^I start the application$/ do
  application_start
  @application.should be_running
end

def application_start(options={})
  data_folder = fullpath(File.expand_path(current_dir))
  parameters = options[:parameters].to_s + " --nosplash --data_folder:#{data_folder}"
  @application = Myapp.new  :parameters => parameters
  if @application.dialog_login(:timeout => 5)
    @application.dialog_login.set_focus
    keystroke(VK_RETURN)
  end
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

