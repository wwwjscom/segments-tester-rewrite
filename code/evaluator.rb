require_relative "configs"

class Evaluator < Application

	attr_accessor :solution, :engine_name

	# Initializes with an engines candidates, and the solution info
	def initialize(candidates, solution, solution_id, engine_name)
		@candidates  = candidates
		@solution    = solution
		@solution_id = solution_id
		@engine_name = engine_name
	end
	
	# Returns {:rank => rank, :found => found}
	# This method should be used in place of the individual methods
	# since we consider a record 'not found' if it is above a
	# particular rank threshold (which is defined in the config)
	def found_and_rank
		sorted = @candidates.sort_by_rank
		sorted = sorted.collect { |c| [c.solution, c.votes] }
		rank   = sorted.flatten.index(@solution)

    # Solution does not exist within the candidates, thus not found
		if rank == nil then return {:rank => nil, :found => false} end

		# Now find the true rank.  That is, if there is a tie amoung the
		# number of votes, select the index of the first candidate with
		# that many votes, instead of arbitrarly selecting its rank.
		@solution_votes = sorted.flatten[rank+1]
		true_rank = sorted.flatten.index(@solution_votes)
   	
		rank = (true_rank > 1) ? (true_rank/2)+1 : true_rank
		
		if rank > Application.get_config['rank_threshold'].to_i
		  Log.app "[#{@engine_name}] Rank is too high: #{rank}; setting found to false", "DEBUG"
		  return {:rank => nil, :found => false}
	  end
		
		results = {:rank => rank, :found => true}
		
		Log.app("Rank::Solution: #{@solution}", "DEBUG")
		Log.app("Rank::Solution_id: #{@solution_id}", "DEBUG")
		Log.app("Rank::found?: #{results[:found]}", "DEBUG")
		Log.app("Rank::sorted: #{sorted}", "DEBUG")
		Log.app("Rank::rank: #{results[:rank]}", "DEBUG")
		Log.app("-"*50, "DEBUG")
		
		return {:rank => rank, :found => true}
	end

	
	# Returns the confidence
	def confidence
		found_and_rank
		total_votes = @candidates.total_votes
		
		##############################################################################
		##############################################################################
		
		# Wow...this may have been a serious bug.  It looks like it was computing
		# the old confidence by using knowledge of the solution term.  If right, 
		# this shouldn't have been allowed.  The algorithm can't use knowledge
		# of the solution while determining it's candidates...
		
		#		("%.2f" % (@solution_votes.to_f/total_votes.to_f)).to_f
    
		##############################################################################
		##############################################################################
		
		"%.2f" % (@candidates.candidates.first.votes/total_votes.to_f)
	end
	
	# Give two evaluator instances, do the following:
	# If e1 has a confidence lower than the threashold,
	# compare the two and return the higher of the two.
	def self.compare_confidence(e1, e2)
		@config = Configs.read_yml
		Log.app "#{e1.engine_name} confidence: #{e1.confidence}.  #{e2.engine_name} confidence #{e2.confidence}", "DEBUG"
		if e1.confidence <= @config["confidence_threashold"].to_f
			Log.app "Segments confidence below threadhold, considering a change...", "DEBUG"
			ret =  (e1.confidence < e2.confidence) ? "e2" : "e1"
			Log.app('Recomend changing to ngram results', "INFO") if ret == "e2"
		else
			ret = "e1"
		end
		ret
	end
	
end