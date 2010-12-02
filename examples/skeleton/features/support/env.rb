$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')

require 'win32/autogui'
require 'aruba'
require 'spec/expectations'
puts "Cucumber starting"

# puts "Resetting database..."
# `../../script/reset_database`

at_exit do
  puts "Cucumber exiting"
end
