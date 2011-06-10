# encoding: utf-8

# Bundler is managing $LOAD_PATH, any gem needed by this Rakefile must be
# listed as a development dependency in the gemspec
require 'bundler/gem_tasks'

require 'spec'
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
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
                  '--title', "BasicGem #{doc_version} Documentation",
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
