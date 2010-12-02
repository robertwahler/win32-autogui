$LOAD_PATH.unshift File.expand_path('..', __FILE__) unless
  $LOAD_PATH.include? File.expand_path('..', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__) unless
  $LOAD_PATH.include? File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'basic_gem'
require 'spec'
require 'spec/autorun'
require 'aruba/api'
require 'aruba_helper'

Spec::Runner.configure do |config|
   config.include Aruba::Api
end
