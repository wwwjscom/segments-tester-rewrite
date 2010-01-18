#task :default => [:some_rake_task]

require 'rake'
require 'spec/rake/spectask'

namespace "test" do
	desc 'Run all rspec tests'
	Spec::Rake::SpecTask.new('rspec') do |t|
		t.spec_files = FileList['tests/**/*.rb']
	end

	desc 'Setup the test db'
	task :setup do
		require "lib/tasks/prepare_tests_db"
		ptdb = PrepareTestsDb.new
		ptdb.setup
	end
end