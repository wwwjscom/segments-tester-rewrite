#task :default => [:some_rake_task]
require 'rake'
require_relative 'code/application'

#require 'spec/rake/spectask'

namespace "setup" do
	
	desc "Setup the solutions tables"
	task :tables do
		require_relative "lib/setup_solutions_tables"
		sst = SetupSolutionsTables.new
		
		# Setup queries table where mispelled queries
		# will be pulled from, and cnadidates will be
		# checked against
		Application::Log.to_term("Setting up misspelled table", "DEBUG")
		sst.drop_table('misspelled')
		sst.setup_queries_table
		
		# Generate and insert the 3grams
		Application::Log.to_term("Setting up 3grams table", "DEBUG")
		sst.drop_table('3grams')
		sst.generate_ngrams(3)
		
		# Generate and insert the 4grams
		Application::Log.to_term("Setting up 4grams table", "DEBUG")
		sst.drop_table('4grams')
		sst.generate_ngrams(4)
		
		# Generate and insert DM Soundex
		Application::Log.to_term("Setting up DM Soundex table", "DEBUG")
		Application::Log.to_term("This may take a while...", "DEBUG")
		sst.drop_table('dm_soundex')
		sst.generate_dm_soundex_encodings
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
  	require_relative "code/main"
  	m = Main.new
  	m.search_type = :query_logs
  	m.run
  end

  desc "Run the program using synthetic queries"
  task :synthetic do
  	require_relative "code/main"
  	
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


  desc "Data Set Statistics"
  task :stats do
	  require_relative "lib/stats"
	  s = Stats.new
	  puts "Data Set size: #{s.count}"
	  puts "Query Length:"
	  puts "\tAvg: #{s.avg_query_length}"
	  puts "\tMin: #{s.min_query_length}"
	  puts "\tMax: #{s.max_query_length}"
	  puts "\tMedian: #{s.median_query_length}"
	  puts "\tMode: #{s.mode_query_length}"
  end
end

task :tables => ["setup:tables"]
