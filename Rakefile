#task :default => [:some_rake_task]

require 'rake'
require 'spec/rake/spectask'

namespace :setup do
	
	desc "Setup the solutions tables"
	task :s_tables do
		require "lib/setup_solutions_tables"
		sst = SetupSolutionsTables.new
		
		# Generate and insert the 3grams
		sst.drop_table('_3grams')
		sst.generate_ngrams(3)
		sst.insert_ngrams(3)
		
		# Generate and insert the 4grams
		sst.drop_table('_4grams')
		sst.generate_ngrams(4)
		sst.insert_ngrams(4)
		
		# Generate and insert DM Soundex
		sst.drop_table('_dm_soundex')
		sst.generate_dm_soundex_encodings
		sst.insert_dm_soundex_encodings
	end
	
end

namespace "test" do
	desc 'Run all rspec tests'
	Spec::Rake::SpecTask.new('rspec') do |t|
		t.spec_files = FileList['tests/**/*.rb']
	end

	desc 'Setup the test db'
	task :setup do
		require "lib/prepare_tests_db"
		ptdb = PrepareTestsDb.new
		ptdb.setup
	end
end