$LOAD_PATH.unshift File.expand_path('..', __FILE__) unless
  $LOAD_PATH.include? File.expand_path('..', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__) unless
  $LOAD_PATH.include? File.expand_path('../../lib', __FILE__)

# use development version of win32/autogui
# remove these lines in production code
$LOAD_PATH.unshift File.expand_path('../../../../lib', __FILE__) unless
  $LOAD_PATH.include? File.expand_path('../../../../lib', __FILE__)

require 'rubygems'
require 'win32/autogui'
require 'quicknote'
require 'spec'
require 'spec/autorun'
require 'aruba/api'

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
