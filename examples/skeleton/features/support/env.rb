$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')

require 'win32/autogui'
require 'aruba/cucumber'
require 'rspec/expectations'
require File.expand_path(File.dirname(__FILE__) + '/../../spec/aruba_helper')

puts "Cucumber starting"

# puts "Resetting database..."
# `../../script/reset_database`

at_exit do
  puts "Cucumber exiting"
end

Before do
  @aruba_timeout_seconds = 10
end
