$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'rubygems'
require 'basic_gem'
require 'aruba/cucumber'
require 'rspec/expectations'
require File.expand_path(File.dirname(__FILE__) + '/../../spec/aruba_helper')

Before do
  @aruba_timeout_seconds = 10
end
