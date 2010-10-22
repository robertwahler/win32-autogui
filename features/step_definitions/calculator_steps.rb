require File.expand_path(File.dirname(__FILE__) + '../../../spec/applications/calculator')

include Autogui::Input

After('@calculator') do
  if @calculator
    @calculator.close(:wait_for_close => true) if @calculator.running?
    @calculator.should_not be_running
  end
end

Given /^A GUI application named calculator$/ do 
  @calculator = Calculator.new
  @calculator.should be_running
end

When /^I type in "([^"]*)" and hit return$/ do |arg1|
  @calculator.set_focus
  # TODO: need type_in function
  keystroke(VK_2, VK_ADD, VK_2, VK_RETURN) 
end

# "the window text should match" allows regex in the partial_output, if
# you don't need regex, use "the output should contain" instead since
# that way, you don't have to escape regex characters that
# appear naturally in the output
Then /^the edit window text should match \/([^\/]*)\/$/ do |partial_output|
  @calculator.edit_window.text.should =~ /#{partial_output}/
end

