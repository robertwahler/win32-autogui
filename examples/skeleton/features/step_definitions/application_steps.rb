require 'myapp'

include Autogui::Input

After('@application') do
  if @application
    @application.close(:wait_for_close => true) if @application.running?
    @application.should be_running
  end
end

Before('@applicaton') do
  @application = Myapp.new
  @application.should_not be_running

  # debug
  puts "application:"
  puts @application.inspect
  puts "application.combined_text"
  puts @application.combined_text
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

