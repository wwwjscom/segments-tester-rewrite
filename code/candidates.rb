class Candidates
	
	attr_accessor :candidates		
	
	def initialize
		@candidates = Array.new # An array of candidate objects
	end
	
	def prune
	 @candidates.delete_if { |x| x.votes < 1 }
	end
	
	def add(candidate)
		@candidates << candidate
	end
	
	# Removes the candidate at the specified index
	def remove(index)
		@candidates.delete_at(index)
	end
	
	# Returns whether or not the array contains a candidate with this
	# solution id
	def has_id?(id)
		@candidates.collect(&:id).include?(id)
	end
	
	def has_solution?(solution)
		@candidates.collect(&:solution).include?(solution)
	end
	
	# Increments the votes of the given candidate by the value.
	# Returns the affected candidate object
	def vote_for(id, value)
		candidate = @candidates[@candidates.collect(&:id).index(id)]
		candidate.votes += value
		candidate
	end
	
	# Returns the hash of the candidate that has a solution
	# matching the given param
	def find_by_solution(solution)
		begin
			@candidates[@candidates.collect(&:solution).index(solution)]
		rescue
			false
		end
	end
	
	# Returns an array of candidates, sorted by their rank
	def sort_by_rank
		sorted = @candidates.sort{ |x,y| y.votes <=> x.votes }
	end

	# Returns the total number of votes
	def total_votes
		@candidates.inject(0) { |sum, c| sum + c.votes }
	end
	
	# Returns the number of candidates
	def size
		@candidates.size
	end
	
	# Pretty prints the array of candidates
	def to_s
		s = ''
		unless @candidates == nil
			@candidates.each do |c|
				s += "[#{c.id}, #{c.misspelled}, #{c.solution}, #{c.votes}], "
			end
		end
	end
end

class Candidate < Candidates

	attr_accessor :id, :misspelled, :solution, :votes

	def initialize(misspelled, solution, id, votes = 0.0)
		@misspelled = misspelled
		@solution   = solution
		@id         = id
		@votes		= votes
		self
	end
end