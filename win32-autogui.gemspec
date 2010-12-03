# -*- encoding: utf-8 -*-
#
#

require 'rbconfig'
WINDOWS = Config::CONFIG['host_os'] =~ /mswin|mingw/i unless defined?(WINDOWS)

Gem::Specification.new do |s|
  # wrap 'git' so we can get gem files even on systems without 'git'
  #
  # @see spec/gemspec_spec.rb
  #
  @gemfiles ||= begin
    filename  = File.join(File.dirname(__FILE__), '.gemfiles')
    # backticks blows up on Windows w/o valid binary, use system instead
    if File.directory?('.git') && system('git ls-files bogus-filename')
      files = `git ls-files`
      cached_files = File.exists?(filename) ? File.open(filename, "r") {|f| f.read} : nil
      # maintain EOL
      files.gsub!(/\n/, "\r\n") if cached_files && cached_files.match("\r\n")
      File.open(filename, 'wb') {|f| f.write(files)} if cached_files != files
    else
      files = File.open(filename, "r") {|f| f.read}
    end
    raise "unable to process gemfiles" unless files
    files.gsub(/\r\n/, "\n")
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

  s.add_dependency "windows-api", ">= 0.4.0"
  s.add_dependency "windows-pr", ">= 1.1.2"
  s.add_dependency "win32-process", ">= 0.6.4"
  s.add_dependency "win32-clipboard", ">= 0.5.2"
  s.add_dependency "log4r", ">= 1.1.9"

  s.add_development_dependency "bundler", ">= 1.0.7"
  s.add_development_dependency "rspec", "= 1.3.1"
  s.add_development_dependency "cucumber", ">= 0.9.4"
  s.add_development_dependency "aruba", "= 0.2.2"
  s.add_development_dependency "rake", ">= 0.8.7"
  s.add_development_dependency "yard", ">= 0.6.2"

  # Specify a markdown gem for rake doc:generate
  #
  # Without the development dependency, running yard rake
  # tasks will fail.  Kramdown chosen to provide a pure Ruby solution.
  s.add_development_dependency "kramdown", ">= 0.12.0"

  s.add_development_dependency "win32console", ">= 1.2.0" if WINDOWS

  s.files        = @gemfiles.split("\n")
  s.executables  = @gemfiles.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact

  s.require_path = 'lib'

  s.has_rdoc = 'yard'
  s.rdoc_options     = [
                         '--title', 'Win32-Autogui Documentation',
                         '--main', 'README.markdown',
                         '--line-numbers',
                         '--inline-source'                       
                       ]
end
