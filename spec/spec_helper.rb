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
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
