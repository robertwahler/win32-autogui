$LOAD_PATH.unshift File.expand_path('..', __FILE__) unless
  $LOAD_PATH.include? File.expand_path('..', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__) unless
  $LOAD_PATH.include? File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'win32/autogui'
require 'rspec/core'
require 'aruba/api'
require 'aruba_helper'

# applications
require File.expand_path(File.dirname(__FILE__) + '/applications/calculator')
require File.expand_path(File.dirname(__FILE__) + '/applications/notepad')

RSpec.configure do |config|
   config.include Aruba::Api
end
