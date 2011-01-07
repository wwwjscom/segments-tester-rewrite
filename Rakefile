#task :default => [:some_rake_task]
require 'rake'

#require 'spec/rake/spectask'

namespace "setup" do
	
	desc "Setup the solutions tables"
	task :tables do
		require "lib/setup_solutions_tables"
		sst = SetupSolutionsTables.new
		
		# Setup queries table where mispelled queries
		# will be pulled from, and cnadidates will be
		# checked against
		sst.drop_table('_misspelled')
		sst.setup_queries_table
		
		
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
	
	desc "Setup and run all rspec tests"
	task :run => [:tables, :rspec] do
	end
	
#	desc 'Run all rspec tests'
#	Spec::Rake::SpecTask.new('rspec') do |t|
#		t.spec_files = FileList['tests/**/*.rb']
#	end

#	# This task should be deprecated
#	desc 'Setup the test db -- deprecated...?'
#	task :setup do
#		require "lib/prepare_tests_db"
#		ptdb = PrepareTestsDb.new
#		ptdb.setup
#	end
end

namespace "run" do
  desc "Setup and run the program"
  #task :default => [:tables] do
  task :default do
  	require "code/main"
  	m = Main.new
  	m.search_type = :query_logs
  	m.run
  end

  desc "Run the program using synthetic queries"
  task :synthetic do
  	require "code/main"
  	
  	FUNCTIONS = [["drop_chrs", 1], ["drop_chrs", 2], ["drop_chrs", 3], ["drop_chrs", 4],
      ["add_chrs", 1], ["add_chrs", 2], ["add_chrs", 3], ["add_chrs", 4],
      ["replace_chrs", 1], ["replace_chrs", 2], ["replace_chrs", 3], ["replace_chrs", 4],
      ["swap_adj_chr", 1], ["swap_chrs", 2], ["swap_chrs", 3], ["swap_chrs", 4]]
  	
  	  if ENV["SYNTH_FUNC"] == nil
        raise "You must set the enviornmental veriable SYNTH_FUNC.  See rake -T"
      end
  	
  	if ENV["SYNTH_FUNC"].downcase == "all"
  	  FUNCTIONS.each do |function|
        method = function[0]
        times  = function[1]
        ENV["SYNTH_FUNC"] = method
        ENV["SYNTH_TIMES"] = times.to_s
        m = Main.new
      	m.search_type = :synthetic
      	m.run
      end
  	end
  	m = Main.new
  	m.search_type = :synthetic
  	m.run  
  end
end

task :tables => ["setup:tables"]
