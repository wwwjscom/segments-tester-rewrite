class Evaluator

	# Initializes with an engines candidates hash, and the solution
	def initialize(candidates_hash, solution)
		@candidates_hash = candidates_hash
		@solution = solution
	end
	
	# Returns whether the solution was found in the candidates
	def found?
		@candidates_hash.key?(@solution)
	end
	
	# Returns the solutions rank within the candidates, if found
	def rank
		raise "Error, can't find rank of an unfound result." if not found?
		
		sorted = @candidates_hash.sort{ |x,y| y[1] <=> x[1] }
		rank = sorted.flatten.index(@solution)
		
		# Now find the true rank.  That is, if there is a tie amoung the
		# number of votes, select the index of the first candidate with
		# that many votes, instead of arbitrarly selecting its rank.
		votes = sorted.flatten[rank+1]
		true_rank = sorted.flatten.index(votes)
		
		(true_rank > 0) ? true_rank-1 : true_rank
	end
end