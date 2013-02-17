require_relative "application"
require_relative "candidates"
require_relative "configs"
require "rubygems"
#require 'amatch'

class EditDistance < Application
	
	attr_accessor :all_solutions
	
	def initialize(query)
		@config = Configs.read_yml
		@query = query.downcase
		@ed = Amatch::Levenshtein.new(@query)
		@candidates = Candidates.new
		prepare
	end
	
	def prepare
		# this should really only be called once!
		s = SQL.new
		s.populate
		@all_solutions = []
		while s.has_next? do
			nxt = s.next
			@candidates.add Candidate.new(@query, nxt["solution"], nxt["id"])
			@all_solutions << nxt["solution"]
		end
		# End shittness
	end
	
	# Returns the edit distance of the self.query and candidates
	def match(candidates)
		self.downcase(candidates)
		@ed.match(candidates)
	end
	
	# Matches the edit distance to a candidate of the same index in a different
	# array.  This method is called right after match to pair up candidates and
	# their respective edit distances.
	def combine(distances)
		if distances.class == Fixnum
			# This should never be the case -- we should not be
			# searching using just one candidate, but instead we should
			# have many candidates
		elsif distances.class == Array
			# An array of distances
			
			to_remove = []
			
			(0..@candidates.size-1).each do |i|
				ed = distances[i]
				#Log.ed "#{@candidates.candidates[i].solution} has an ed of #{ed} to #{@candidates.candidates[i].misspelled}"
				if ed >= @config["edit_distance_prune_at"]
					# Remove the candidate if its above the pruning level
					# Remove only after we drop out of our loop.
					to_remove << i
					#Log.ed "Removing, ed is too high: #{ed}."
				else
					@candidates.candidates[i].votes = ed # Here, the edit distance value is votes
				end				
			end # Loop
		end
		
		# Now that we're out of the loop, prune the candidates
		to_remove.each do |i|
			@candidates.remove(i)
		end
		
		@candidates
	end

	# Normalizes the candidates to downcase since
	# edit distance is case sensitive
	def downcase(candidates)
		if candidates.class == Array
			candidates.map!(&:downcase)
		elsif candidates.class == String
			candidates.downcase!
		end
	end
	
end