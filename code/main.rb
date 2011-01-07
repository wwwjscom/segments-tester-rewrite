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
		@config   = Configs.read_yml
		@s_3grams = Stats.new('3grams')
		@s_4grams = Stats.new('4grams')
		@s_dm     = Stats.new('DM Soundex')
		@s_seg    = Stats.new('Segments')
		@s_ed     = Stats.new('Edit Distance') if Application.use_edit_disance?(@config)
    @max_tests = Application.get_config["max_tests"]
		# Declare stats instance variables here, since we'll be adding
		# to them over the life of the program
	end

	def run
		to_terminal "Inside run"
		i=0
	  setup_queries
    @queries.all.each do |query|
      to_terminal '-'*50
      #p @queries.all.size	
      solution_id = query.solution_id
      solution    = query.solution
      misspelled  = query.misspelled

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
      
  		to_terminal "Swap?"
      swap_results?
      
  		to_terminal "Adding results"
      add_results
      
  		to_terminal "Logging findings"
      log_findings
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
      sql = SQL.new
  	 	sql.populate(@config) # setup function
  	  sql.to_queries
	  when :synthetic
	    sql = SQL.new
  	 	sql.populate(@config) # setup function
      
      queries = Queries.new
      
      method = ENV["SYNTH_FUNC"].downcase
      times = (ENV["SYNTH_TIMES"] == nil) ? 1 : ENV["SYNTH_TIMES"].to_i
      
      while sql.has_next?
        query = sql.next  			
        s = Synthetic.new(query["id"], query["solution"], query["misspelled"])        
        queries << s.to_synthetic(method, times).to_query
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

		results_from_this_query
  end
  
  
  # Segments failed to meet the threshold, and is lower than 3grams,
	# so use the 3grams results for segments.
  def swap_results?
    if Evaluator.compare_confidence(@eval_seg, @eval_3grams) == "e2"
			@eval_seg = @eval_3grams
			Log.app 'Changing...'
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
    Log.seg "Segments Found? #{stats[:found]}"
		Log.seg "Segments Rank: #{stats[:rank]}" if stats[:found]
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
