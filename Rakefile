# encoding: utf-8

# Bundler is managing $LOAD_PATH, any gem needed by this Rakefile must be
# listed as a development dependency in the gemspec
require 'bundler/setup'
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
desc "Run RSpec"
RSpec::Core::RakeTask.new do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--color', '--format nested']
end

require 'cucumber'
require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |task|
  task.cucumber_opts = ["features"]
end

desc "Run specs and features"
task :test => [:spec, :features]

task :default => :test

# put the gemfiles task in the :build dependency chain
task :build => [:gemfiles]

desc "Generate .gemfiles via 'git ls-files'"
task :gemfiles do
  files = `git ls-files`

  filename  = File.join(File.dirname(__FILE__), '.gemfiles')
  cached_files = nil
  if File.exists?(filename)
    puts ".gemfiles exists, reading..."
    cached_files = File.open(filename, "rb") {|f| f.read}
  end

  if cached_files && cached_files.match("\r\n")
    puts ".gemfiles using DOS EOL"
    files.gsub!(/\n/, "\r\n")
  end

  if cached_files != files
    puts ".gemfiles updating"
    File.open(filename, 'wb') {|f| f.write(files)}
  else
    puts ".gemfiles update not required"
  end

  raise "unable to process .gemfiles" unless files
end
