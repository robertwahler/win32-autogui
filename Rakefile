# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

begin
  require 'spec'
  require 'spec/rake/spectask'

  Spec::Rake::SpecTask.new(:spec) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.spec_files = FileList['spec/**/*_spec.rb']
  end

rescue LoadError
  desc "Run specs [*LoadError*]"
  task :spec do
    abort "Please install the Rspec gem to run specs"
  end
end


require 'cucumber'
require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features) do |task|
  task.cucumber_opts = ["features"]
end


namespace :doc do
  project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  doc_destination = File.join(project_root, 'rdoc')

  begin
    require 'yard'
    require 'yard/rake/yardoc_task'

    YARD::Rake::YardocTask.new(:generate) do |yt|
      # todo: pull files from gemspec
      yt.files   = Dir.glob(File.join(project_root, 'lib', '**', '*.rb')) + 
                   [ File.join(project_root, 'README.markdown') ]
      yt.options = ['--output-dir', doc_destination, '--readme', 'README.markdown']
    end
  rescue LoadError
    desc "Generate YARD Documentation [*LoadError*]"
    task :generate do
      abort "Please install the YARD gem to generate rdoc"
    end
  end

  desc "Remove generated documenation"
  task :clean do
    rm_r doc_destination if File.exists?(doc_destination)
  end

end
