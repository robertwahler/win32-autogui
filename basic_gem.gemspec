# -*- encoding: utf-8 -*-
#
#

Gem::Specification.new do |s|
  s.name        = "basic_gem"
  s.version     = File.open(File.join(File.dirname(__FILE__), *%w[VERSION]), "r") { |f| f.read } 
  s.platform    = Gem::Platform::RUBY
  s.authors     = []
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/basic_gem"
  s.summary     = "TODO: Write a gem summary"
  s.description = "TODO: Write a gem description"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "basic_gem"

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
                         '--title', 'BasicGem Documentation', 
                         '--main', 'README.markdown', 
                         '--line-numbers',
                         '--inline-source' 
                       ]
end
