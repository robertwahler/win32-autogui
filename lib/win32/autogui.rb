# require all files here
require 'win32/autogui/input'
require 'win32/autogui/window'
require 'win32/autogui/application'

# Master namespace
module Autogui
  
  # Contents of the VERSION file
  #
  # Example format: 0.0.1
  #
  # @return [String] the contents of the version file in #.#.# format
  def self.version
    version_info_file = File.join(File.dirname(__FILE__), *%w[.. .. VERSION])
    File.open(version_info_file, "r") do |f|
      f.read.strip
    end
  end

  # @return False (nil) or True (Integer)
  def self.win32?
    RUBY_PLATFORM =~ /mingw|mswin|cygwin/i
  end

end

