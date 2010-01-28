require "code/configs"

class Evaluator < Application

	attr_accessor :solution

	# Initializes with an engines candidates, and the solution info
	def initialize(candidates, solution, solution_id)
		@candidates  = candidates
		@solution    = solution
		@solution_id = solution_id
	end
	
	# Returns whether the solution was found in the candidates
	def found?
		@candidates.has_id?(@solution_id)
#		@candidates.has_solution?(@solution)
	end
	
	# Returns the solutions rank within the candidates, if found
	def rank		
		sorted = @candidates.sort_by_rank
		sorted = sorted.collect { |c| [c.solution, c.votes] }
		rank   = sorted.flatten.index(@solution)

		if rank == nil then return end

		# Now find the true rank.  That is, if there is a tie amoung the
		# number of votes, select the index of the first candidate with
		# that many votes, instead of arbitrarly selecting its rank.
		@solution_votes = sorted.flatten[rank+1]
		true_rank = sorted.flatten.index(@solution_votes)
		
		(true_rank > 1) ? (true_rank/2)+1 : true_rank
	end
	
	# Returns the confidence
	def confidence
		rank
		total_votes = @candidates.total_votes
		("%.2f" % (@solution_votes.to_f/total_votes.to_f)).to_f
	end
	
	# Give two evaluator instances, do the following:
	# If e1 has a confidence lower than the threashold,
	# compare the two and return the higher of the two.
	def self.compare_confidence(e1, e2)
		@config = Configs.read_yml
		Log.app "e1 confidence: #{e1.confidence}.  e2 confidence #{e2.confidence}"
		if e1.confidence <= @config["confidence_threashold"].to_f
			Log.app 'Recomend changing to ngram results'
			ret =  (e1.confidence < e2.confidence) ? "e2" : "e1"
		else
			ret = "e1"
		end
		ret
	end
	
end