require 'yaml'
require "code/sql"
require "code/configs"
require "code/tester"
require "code/application"
require "code/evaluator"
require "code/stats"
require "code/synthetic"

class Main < Application

  attr_writer :search_type
	attr_reader :config

	def initialize
		Log.clear
	  Log.to_term("Initializing", "DEBUG")
		@config   = Configs.read_yml
		@s_3grams = Stats.new('3grams')
		@s_4grams = Stats.new('4grams')
		@s_dm     = Stats.new('DM Soundex')
		@s_seg    = Stats.new('Segments')
		@s_ed     = Stats.new('Edit Distance') if Application.use_edit_disance?(@config)
    @max_tests = Application.get_config["max_tests"]
		# Declare stats instance variables here, since we'll be adding
		# to them over the life of the program
		Log.to_term("Done initializing", "DEBUG")
	end

	def run
		to_terminal "Inside run"
		i=0
	  setup_queries
    @queries.all.each do |query|
      #p @queries.all.size	
      solution_id = query.solution_id
      solution    = query.solution
      misspelled  = query.misspelled

      Log.app "==============================================="
      Log.app "Start search for #{solution} as #{misspelled}"

      i+=1
      
      break if @max_tests != -1 && i >= @max_tests
      
      log_intermediary_results if i%Application.get_config["log_stats_every_x_runs"].to_i == 0
      
      to_terminal "Running - #{i}/#{@queries.all.size}"

      to_terminal ""
  		to_terminal "Solution: #{solution}"
  		to_terminal "Misspelling: #{misspelled}"

      next if solution.downcase.include?("j")
      next if misspelled.downcase.include?("j")
      next if solution.size < 4 || misspelled.size < 4

      Log.seg("-"*50)
			Log.seg "Misspelled: #{misspelled}"
			Log.seg "Solution: #{solution}"

			to_terminal "Finding..."
      find(solution_id, solution, misspelled)
      
			Log.app ""
			Log.app "---- Start Pre-(potential)-swap results: ----"
			results_from_this_query
			Log.app "---- End Pre-(potential)-swap results: ----"
			Log.app ""
			

  		to_terminal "Swap?"
      swap_results?
      
  		to_terminal "Adding results"
      add_results
      
  		to_terminal "Logging findings"
      log_findings

			Log.app ""
			Log.app "---- Start Post-(potential)-swap results: ----"
			results_from_this_query
			Log.app "---- End Post-(potential)-swap results: ----"
			Log.app ""
			
			Log.app "End search for #{solution} as #{misspelled}"
			Log.app "==============================================="
		end

		to_terminal "Calculating stats"
    calculate_stats

		# Display the results
		unless SEG_ENV =~ /test/i
			puts @s_3grams.to_s
			puts @s_4grams.to_s
			puts @s_dm.to_s
			puts @s_seg.to_s
			puts @s_ed.to_s if Application.use_edit_disance?(@config)
			
			Log.stats @s_3grams.to_s
			Log.stats @s_4grams.to_s
			Log.stats @s_dm.to_s
			Log.stats @s_seg.to_s
			Log.stats @s_ed.to_s if Application.use_edit_disance?(@config)
		end

	end
	
	def log_intermediary_results
	  to_terminal "Calculating intermediary stats"
    calculate_stats
    Log.intermediary_stats "-"*50
    Log.intermediary_stats "#{ENV["SYNTH_FUNC"]} x#{ENV["SYNTH_TIMES"]}"
    Log.intermediary_stats @s_3grams.to_s
		Log.intermediary_stats @s_4grams.to_s
		Log.intermediary_stats @s_dm.to_s
		Log.intermediary_stats @s_seg.to_s
		Log.intermediary_stats @s_ed.to_s if Application.use_edit_disance?(@config)
	end
	
	# Populates the queries instance variable based on the search type
	# so that we can later iterate over them.
	def setup_queries
		to_terminal "in setup_queries"
	  @queries = case @search_type
    when :query_logs
      Log.to_term("Search Type: Query Logs", "DEBUG")
      sql = SQL.new
  	 	sql.populate(@config) # setup function
  	  sql.to_queries
	  when :synthetic
	    Log.to_term("Search Type: Syntehtic", "DEBUG")
	    sql = SQL.new
	    Log.to_term("Populating results", "DEBUG")
  	 	results = sql.populate(@config) # setup function
      Log.to_term("Done populating", "DEBUG")
  	  
      queries = Queries.new
      
      method = ENV["SYNTH_FUNC"].downcase
      times = (ENV["SYNTH_TIMES"] == nil) ? 1 : ENV["SYNTH_TIMES"].to_i
      Log.to_term("SYNTH_FUNC: #{method}", "DEBUG")
      Log.to_term("SYNTH_TIMES: #{times}", "DEBUG")

      size = sql.queries.size
      Log.to_term("Queries size: #{size}", "DEBUG")
      i=1
      sql.queries.each do |query|
        Log.to_term("#{i}/#{size}", "DEBUG")
        Log.to_term("---- query.id:\t\t#{query.id}", "DEBUG")
        Log.to_term("---- query.solution:\t\t#{query.solution}", "DEBUG")
        Log.to_term("---- query.misspelled:\t\t#{query.misspelled}", "DEBUG")
        
        s = Synthetic.new(query.id, query.solution, query.misspelled)
        queries << s.to_synthetic(method, times).to_query
        i += 1
      end
      
		to_terminal "leaving setup_queries"

		Log.stats "-- #{method} #{times} --"
    to_terminal "-- #{method} #{times} --"
      
      queries
    end # case
  end
	
	
	# Done adding results, calculate stats
	def calculate_stats
		@s_3grams.calculate
		@s_4grams.calculate
		@s_dm.calculate
		@s_seg.calculate
		@s_ed.calculate if Application.use_edit_disance?(@config)
		
	 	@s_seg.common_rank(@s_3grams)
	 	@s_3grams.common_rank(@s_seg)
	
	end
	
	
	def find(solution_id, solution, misspelled)
    @t = Tester.new
		@t.find(misspelled)

		#      puts "Solution: #{solution}"
		@eval_3grams = Evaluator.new(@t.grams_3_candidates, solution, solution_id, "3grams")
		@eval_4grams = Evaluator.new(@t.grams_4_candidates, solution, solution_id, "4grams")
		@eval_dm     = Evaluator.new(@t.dm_candidates, solution, solution_id, "dm")
		@eval_seg    = Evaluator.new(@t.seg_candidates, solution, solution_id, "seg")
		@eval_ed     = Evaluator.new(@t.ed_candidates, solution, solution_id, "eg") if Application.use_edit_disance?(@config)
  end
  
  
  # Segments failed to meet the threshold, and is lower than 3grams,
	# so use the 3grams results for segments.
  def swap_results?
    if Evaluator.compare_confidence(@eval_seg, @eval_3grams) == "e2"
			@eval_seg = @eval_3grams
			Log.app 'Changing...', "DEBUG"
			Log.term "[Segments] Changing results"
		end
  end
  
  
  # Add to the stats instance variables
  def add_results
    @s_3grams.add(@eval_3grams)
		@s_4grams.add(@eval_4grams)
		@s_dm.add(@eval_dm)
		@s_seg.add(@eval_seg)
		@s_ed.add(@eval_ed) if Application.use_edit_disance?(@config)
  end
  
  
  # Log some information
  def log_findings
    stats = @eval_seg.found_and_rank
    Log.seg "Segments Found? #{stats[:found]}", "DEBUG"
		Log.seg ("Segments Rank: #{stats[:rank]}", "DEBUG") if stats[:found]
		#Log.seg "Candidates: #{@t.seg_candidates.to_s}"
		# ...
  end


	def results_from_this_query

		Log.app ""
		Log.app '3GRAMS'
		#to_terminal @t.grams_3_candidates
		stats = @eval_3grams.found_and_rank
		Log.app "\tFound:#{stats[:found]}"
		Log.app "\tRank:#{stats[:rank]}" if stats[:found]

		Log.app '4GRAMS'
		#to_terminal @t.grams_4_candidates
		stats = @eval_4grams.found_and_rank
		Log.app "\tFound:#{stats[:found]}"
		Log.app "\tRank:#{stats[:rank]}" if stats[:found]

		Log.app 'DM-Soundex'
		#to_terminal @t.dm_candidates
		stats = @eval_dm.found_and_rank
		Log.app "\tFound:#{stats[:found]}"
		Log.app "\tRank:#{stats[:rank]}" if stats[:found]

		Log.app 'SEGMENTS'
		#to_terminal @t.seg_candidates
		stats = @eval_seg.found_and_rank
		Log.app "\tFound:#{stats[:found]}"
		Log.app "\tRank:#{stats[:rank]}" if stats[:found]
		
		Log.app ""
    
	end
	
	def to_terminal(msg)
	  Log.to_term(msg)
	end

end

