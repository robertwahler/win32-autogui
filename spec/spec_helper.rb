$LOAD_PATH.unshift File.expand_path('..', __FILE__) unless
  $LOAD_PATH.include? File.expand_path('..', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__) unless
  $LOAD_PATH.include? File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'win32/autogui'
require 'spec'
require 'spec/autorun'
require 'aruba/api'

# applications
require File.expand_path(File.dirname(__FILE__) + '/applications/calculator')

# aruba helper, returns full path to files in the aruba tmp folder
def fullpath(filename)
  path = File.expand_path(File.join(current_dir, filename))
  path = `cygpath -w #{path}`.chomp if path.match(/^\/cygdrive/)  # cygwin?
  path
end

# return the contents of "filename" in the aruba tmp folder
def get_file_content(filename)
  in_current_dir do
    IO.read(filename)
  end
end

Spec::Runner.configure do |config|
   config.include Aruba::Api
end
