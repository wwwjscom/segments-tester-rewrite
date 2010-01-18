#task :default => [:some_rake_task]

require 'rake'
require 'spec/rake/spectask'

desc 'Run all rspec tests'
Spec::Rake::SpecTask.new('test') do |t|
	t.spec_files = FileList['tests/**/*.rb']
end