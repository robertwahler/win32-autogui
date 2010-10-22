# encoding: utf-8

# bundler/setup is managing $LOAD_PATH, any gem needed by this Rakefile must 
# be listed as a development dependency in the gemspec

require 'rubygems'
require 'bundler/setup' 

Bundler::GemHelper.install_tasks

def gemspec
  @gemspec ||= begin
    file = File.expand_path('../win32-autogui.gemspec', __FILE__)
    eval(File.read(file), binding, file)
  end
end

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
  project_root = File.expand_path(File.dirname(__FILE__))
  doc_destination = File.join(project_root, 'rdoc')

  require 'yard'
  require 'yard/rake/yardoc_task'

  YARD::Rake::YardocTask.new(:generate) do |yt|
    yt.options = ['--markup-provider', 'rdiscount', 
                  '--output-dir', doc_destination
                 ] +
                 gemspec.rdoc_options - ['--line-numbers', '--inline-source']
  end

  desc "Remove generated documenation"
  task :clean do
    rm_r doc_destination if File.exists?(doc_destination)
  end

end
