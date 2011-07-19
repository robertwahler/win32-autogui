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

namespace :doc do

  doc_version = File.open(File.join(File.dirname(__FILE__), 'VERSION'), "r") { |f| f.read }
  project_root = File.expand_path(File.dirname(__FILE__))
  doc_destination = File.join(project_root, 'rdoc')

  require 'yard'

  YARD::Rake::YardocTask.new(:generate) do |yt|
    yt.options = ['--output-dir', doc_destination,
                  '--title', "Win32-AutoGUI #{doc_version} Documentation",
                  '--main', "README.markdown"
                 ]
  end

  desc "Remove generated documenation"
  task :clean do
    rm_r doc_destination if File.exists?(doc_destination)
  end

  desc "List undocumented objects"
  task :undocumented do
    system('yard stats --list-undoc')
  end

end

# put the gemfiles task in the :build dependency chain
task :build => [:gemfiles]

desc "Generate .gemfiles via 'git ls-files'"
task :gemfiles do
  files = `git ls-files`

  filename  = File.join(File.dirname(__FILE__), '.gemfiles')
  cached_files = File.exists?(filename) ? File.open(filename, "r") {|f| f.read} : nil

  # maintain EOL
  files.gsub!(/\n/, "\r\n") if cached_files && cached_files.match("\r\n")

  if cached_files != files
    puts "Updating .gemfiles"
    File.open(filename, 'wb') {|f| f.write(files)}
  end

  raise "unable to process gemfiles" unless files
end
