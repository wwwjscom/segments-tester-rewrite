require "code/ngram"

class Tester
	
	attr_accessor :grams_3_candidates, :grams_4_candidates, :dm_candidates
	
	# Queries all of our engines for the given query
	def find(query)
		@grams_3 = Ngram.new(3, query)
		@grams_3_candidates = @grams_3.find
		
		@grams_4 = Ngram.new(4, query)
		@grams_4_candidates = @grams_4.find

		@dm = DMSoundex.new(query)
		@dm_candidates = @dm.find
		# ...
	end	
end