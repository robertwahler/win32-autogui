$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')

require 'win32/autogui'
require 'spec/expectations'
require 'aruba'
require File.expand_path(File.dirname(__FILE__) + '/../../spec/aruba_helper')

puts "Cucumber starting"

# puts "Resetting database..."
# `../../script/reset_database`

at_exit do
  puts "Cucumber exiting"
end
