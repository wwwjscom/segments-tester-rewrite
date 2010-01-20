require "code/evaluator"

class Stats
	
	# Pass in the engine's name
	def initialize(name)
		@name 			= name
		@total_searches = 0
		@total_found	= 0
		@found_percent 	= 0.0
		@average_rank	= 0.0
		@average_rank_a	= []
	end
	
	def add(eval)
		@total_searches += 1
		found = eval.found?
		if found
			@total_found += 1
			@average_rank_a << eval.rank
		end
	end
	
	# Perform calculations when we're done adding results
	def calculate
		average_rank
		found_percent
	end
	
	def average_rank
		@rank = 0.0
		@average_rank_a.each do |r|
			@rank += r
		end
		@average_rank = ("%.2f" % (@rank.to_f/@total_found.to_f)).to_f
	end
	
	def found_percent
		@found_percent = ("%.2f" % ((@total_found.to_f/@total_searches.to_f)*100)).to_f
	end

	def to_s
		"#{@name} found #{@total_found}/#{@total_searches}: #{@found_percent}% with an average rank of #{@average_rank}"
	end
	
end