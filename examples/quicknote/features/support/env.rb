$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')

# use development version of win32/autogui
# remove these lines in production code
$LOAD_PATH.unshift File.expand_path('../../../../../lib', __FILE__) unless
  $LOAD_PATH.include? File.expand_path('../../../../../lib', __FILE__)

require 'win32/autogui'
require 'aruba'
require 'spec/expectations'
