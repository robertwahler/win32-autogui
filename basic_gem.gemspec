# -*- encoding: utf-8 -*-
#
#

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

  s.add_development_dependency "bundler", ">= 1.0.7"
  s.add_development_dependency "rspec", "= 1.3.1"
  s.add_development_dependency "cucumber", ">= 0.9.4"
  s.add_development_dependency "aruba", ">= 0.2.2"
  s.add_development_dependency "rake", ">= 0.8.7"
  s.add_development_dependency "yard", ">= 0.6.2"

  # Specify a markdown gem for rake doc:generate
  #
  # Without the development dependency, running yard rake
  # tasks will fail.  Kramdown chosen to provide a pure Ruby solution.
  s.add_development_dependency "kramdown", ">= 0.12.0"

  s.files        = @gemfiles.split("\n")
  s.executables  = @gemfiles.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact

  s.require_path = 'lib'

  s.has_rdoc = 'yard'
  s.rdoc_options     = [ 
                         '--title', 'BasicGem Documentation', 
                         '--main', 'README.markdown', 
                         '--line-numbers',
                         '--inline-source' 
                       ]
end
