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
#		Log.clear
		@config   = Configs.read_yml
		@s_3grams = Stats.new('3grams')
		@s_4grams = Stats.new('4grams')
		@s_dm     = Stats.new('DM Soundex')
		@s_seg    = Stats.new('Segments')
		@s_ed     = Stats.new('Edit Distance')

		# Declare stats instance variables here, since we'll be adding
		# to them over the life of the program
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

    i+=1
	to_terminal "Running - #{i}/#{@queries.all.size}"

	next if solution.downcase.include?("j")
	next if misspelled.downcase.include?("j")
	next if solution.size < 4 || misspelled.size < 4

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
			puts @s_ed.to_s
			
			Log.stats @s_3grams.to_s
			Log.stats @s_4grams.to_s
			Log.stats @s_dm.to_s
			Log.stats @s_seg.to_s
			Log.stats @s_ed.to_s
		end

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
      puts "-- #{method} #{times} --"
      
      queries
    end # case
  end
	
	
	# Done adding results, calculate stats
	def calculate_stats
		@s_3grams.calculate
		@s_4grams.calculate
		@s_dm.calculate
		@s_seg.calculate
		@s_ed.calculate
		
	 	@s_seg.common_rank(@s_3grams)
	end
	
	
	def find(solution_id, solution, misspelled)
    @t = Tester.new
		@t.find(misspelled)

		#      puts "Solution: #{solution}"
		@eval_3grams = Evaluator.new(@t.grams_3_candidates, solution, solution_id)
		@eval_4grams = Evaluator.new(@t.grams_4_candidates, solution, solution_id)
		@eval_dm     = Evaluator.new(@t.dm_candidates, solution, solution_id)
		@eval_seg    = Evaluator.new(@t.seg_candidates, solution, solution_id)
		@eval_ed     = Evaluator.new(@t.ed_candidates, solution, solution_id)

		#debug(misspelled)
  end
  
  
  # Segments failed to meet the threshold, and is lower than 3grams,
	# so use the 3grams results for segments.
  def swap_results?
    if Evaluator.compare_confidence(@eval_seg, @eval_3grams) == "e2"
			@eval_seg = @eval_3grams
			Log.app 'Changing...'
		end
  end
  
  
  # Add to the stats instance variables
  def add_results
    @s_3grams.add(@eval_3grams)
		@s_4grams.add(@eval_4grams)
		@s_dm.add(@eval_dm)
		@s_seg.add(@eval_seg)
		@s_ed.add(@eval_ed)
  end
  
  
  # Log some information
  def log_findings
    Log.seg "Found? #{@eval_seg.found?}"
		Log.seg "Rank: #{@eval_seg.rank}" if @eval_seg.found?
		Log.seg "Candidates: #{@t.seg_candidates.to_s}"
		# ...
  end


	def debug(misspelled)
		p '-'*50

		p misspelled

		p '3grams'
		p @t.grams_3_candidates
		p @eval_3grams.found?
		p @eval_3grams.rank if @eval_3grams.found?

		p '4grams'
		p @t.grams_4_candidates
		p @eval_4grams.found?
		p @eval_4grams.rank if @eval_4grams.found?

		p 'dm'
		p @t.dm_candidates
		p @eval_dm.found?
		p @eval_dm.rank if @eval_dm.found?

		p 'seg'
		p @t.seg_candidates
		p @eval_seg.found?
		p @eval_seg.rank if @eval_seg.found?
	end
	
	def to_terminal(msg)
		puts "#{Time.now.strftime("%H:%M")} -- #{msg}"
	end

end
