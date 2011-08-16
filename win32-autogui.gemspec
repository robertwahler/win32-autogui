# -*- encoding: utf-8 -*-
#
#

require 'rbconfig'
WINDOWS = Config::CONFIG['host_os'] =~ /mswin|mingw/i unless defined?(WINDOWS)

Gem::Specification.new do |s|
  # avoid shelling out to run git every time the gemspec is evaluated
  #
  # @see spec/gemspec_spec.rb
  #
  gemfiles_cache = File.join(File.dirname(__FILE__), '.gemfiles')
  if File.exists?(gemfiles_cache)
    gemfiles = File.open(gemfiles_cache, "r") {|f| f.read}
    # normalize EOL
    gemfiles.gsub!(/\r\n/, "\n")
  else
    # .gemfiles missing, run 'rake gemfiles' to create it
    # falling back to 'git ls-files'"
    gemfiles = `git ls-files`
  end

  s.name        = "win32-autogui"
  s.version     = File.open(File.join(File.dirname(__FILE__), 'VERSION'), "r") { |f| f.read }
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Wahler"]
  s.email       = ["robert@gearheadforhire.com"]
  s.homepage    = "http://rubygems.org/gems/win32-autogui"
  s.summary     = "Win32 GUI testing framework"
  s.description = "Win32 GUI testing framework"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "win32-autogui"

  s.add_dependency "windows-api", "~> 0.4.0"
  s.add_dependency "windows-pr", "~> 1.2.0"
  s.add_dependency "win32-process", "~> 0.6.5"
  s.add_dependency "win32-clipboard", "~> 0.5.2"
  s.add_dependency "log4r", ">= 1.1.9"

  s.add_development_dependency "bundler", ">= 1.0.14"
  s.add_development_dependency "rspec", ">= 2.6.0"
  s.add_development_dependency "cucumber", "~> 1.0"
  s.add_development_dependency "aruba", "~> 0.4.2"
  s.add_development_dependency "rake", ">= 0.8.7"

  # doc generation
  s.add_development_dependency "yard", ">= 0.7.2"
  s.add_development_dependency "redcarpet", ">= 1.17.2"

  s.add_development_dependency "win32console", ">= 1.2.0" if WINDOWS

  s.files        = gemfiles.split("\n")
  s.executables  = gemfiles.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_paths = ["lib"]

  s.rdoc_options     = [
                         '--title', 'Win32-Autogui Documentation',
                         '--main', 'README.markdown',
                         '--line-numbers',
                         '--inline-source'
                       ]
end
