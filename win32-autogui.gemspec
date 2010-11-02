# -*- encoding: utf-8 -*-
#
#

Gem::Specification.new do |s|
  s.name        = "win32-autogui"
  s.version     = File.open(File.join(File.dirname(__FILE__), *%w[VERSION]), "r") { |f| f.read } 
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Wahler"]
  s.email       = ["robert@gearheadforhire.com"]
  s.homepage    = "http://rubygems.org/gems/win32-autogui"
  s.summary     = "Win32 GUI testing framework"
  s.description = "Win32 GUI testing framework"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "win32-autogui"

  s.add_dependency "windows-api", ">= 0.4.0"
  s.add_dependency "windows-pr", ">= 1.0.9"
  s.add_dependency "win32-process", ">= 0.6.2"
  s.add_dependency "win32-clipboard", ">= 0.5.2"

  s.add_development_dependency "bundler", ">= 1.0.3"
  s.add_development_dependency "rspec", "= 1.3.1"
  s.add_development_dependency "cucumber", ">= 0.9.2"
  s.add_development_dependency "aruba", ">= 0.2.3"
  s.add_development_dependency "rake", ">= 0.8.7"
  s.add_development_dependency "yard", ">= 0.6.1"
  s.add_development_dependency "rdiscount", ">= 1.6.5"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'

  s.has_rdoc = 'yard'
  s.rdoc_options     = [ 
                         '--title', 'Win32-Autogui Documentation', 
                         '--main', 'README.markdown', 
                         '--line-numbers',
                         '--inline-source' 
                       ]
end
