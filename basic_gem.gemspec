# -*- encoding: utf-8 -*-
#
#
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

  s.name        = "basic_gem"
  s.version     = File.open(File.join(File.dirname(__FILE__), 'VERSION'), "r") { |f| f.read }
  s.platform    = Gem::Platform::RUBY
  s.authors     = []
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/basic_gem"
  s.summary     = "TODO: Write a gem summary"
  s.description = "TODO: Write a gem description"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "basic_gem"

  s.add_development_dependency "bundler", ">= 1.0.14"
  s.add_development_dependency "rspec", "= 1.3.1"
  s.add_development_dependency "cucumber", "= 0.9.4"
  s.add_development_dependency "aruba", "= 0.2.2"
  s.add_development_dependency "rake", "= 0.8.7"
  s.add_development_dependency "yard", ">= 0.6.4"

  # Specify a markdown gem for rake doc:generate
  #
  # Without the development dependency, running yard rake
  # tasks will fail.  Kramdown chosen to provide a pure Ruby solution.
  s.add_development_dependency "kramdown", ">= 0.12.0"

  s.files        = gemfiles.split("\n")
  s.executables  = gemfiles.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_paths = ["lib"]

  s.has_rdoc = 'yard'
  s.rdoc_options     = [
                         '--title', 'BasicGem Documentation',
                         '--main', 'README.markdown',
                         '--line-numbers',
                         '--inline-source'
                       ]
end
