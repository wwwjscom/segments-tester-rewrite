require "code/application"
require "code/ngram"
require "code/segments"
require "code/dm_soundex"
require "code/edit_distance"

class Tester < Application
	
	attr_accessor :grams_3_candidates, :grams_4_candidates, :dm_candidates, :seg_candidates, :ed_candidates
	
	# Queries all of our engines for the given query
	def find(query)
		
		threads = []
		
		threads[0] = Thread.new {
			@grams_3 = Ngram.new(3, query)
			@grams_3_candidates = @grams_3.find
		}
		
		threads[1] = Thread.new {
			@grams_4 = Ngram.new(4, query)
			@grams_4_candidates = @grams_4.find
		}

		threads[2] = Thread.new {
			@dm = DMSoundex.new(query)
			@dm_candidates = @dm.find
		}
		
		threads[3] = Thread.new {
			@seg = Segments.new
			@seg_candidates = @seg.find(query)
		}
		
		threads[4] = Thread.new {			
			@ed = EditDistance.new(query)
			distances = @ed.match(@ed.all_solutions)
			@ed_candidates = @ed.combine(distances) # Combine candidates & their edit distances
		}
		
		threads.each { |aThread| aThread.join }
	end	
end