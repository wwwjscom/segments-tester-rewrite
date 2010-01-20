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
		(rank > 0) ? rank-1 : rank
	end
end