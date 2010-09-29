# encoding: utf-8

# bundler/setup is managing $LOAD_PATH, any gem needed by this Rakefile must 
# be listed as a development dependency in the gemspec

require 'rubygems'
require 'bundler/setup' 

Bundler::GemHelper.install_tasks

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


namespace :doc do
  project_root = File.expand_path(File.dirname(__FILE__))
  doc_destination = File.join(project_root, 'rdoc')

  require 'yard'
  require 'yard/rake/yardoc_task'

  YARD::Rake::YardocTask.new(:generate) do |yt|
    # todo: pull files from gemspec
    yt.files   = Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) + 
                 Dir.glob(File.join(project_root, 'features', '**', '*.feature')) + 
                 [ File.join(project_root, 'README.markdown') ] +
                 [ File.join(project_root, 'CLONING.markdown') ]
    yt.options = ['--output-dir', doc_destination, '--readme', 'README.markdown']
    p yt.files
    p "*********"
    p yt.options
  end

  desc "Remove generated documenation"
  task :clean do
    rm_r doc_destination if File.exists?(doc_destination)
  end

end
