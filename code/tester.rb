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
		  start_time = Time.now
		  Thread.current[:name] = "3grams"
			@grams_3 = Ngram.new(3, query)
			@grams_3_candidates = @grams_3.find
			Tester.finalize_thread(start_time)
		}
		
		threads[1] = Thread.new {
		  start_time = Time.now
		  Thread.current[:name] = "4grams"
			@grams_4 = Ngram.new(4, query)
			@grams_4_candidates = @grams_4.find
			Tester.finalize_thread(start_time)
		}

		threads[2] = Thread.new {
		  start_time = Time.now
		  Thread.current[:name] = "dm"
			@dm = DMSoundex.new(query)
			@dm_candidates = @dm.find
			Tester.finalize_thread(start_time)
		}
		
		threads[3] = Thread.new {
		  start_time = Time.now
		  Thread.current[:name] = "seg"
			@seg = Segments.new
			@seg_candidates = @seg.find(query)
			Tester.finalize_thread(start_time)
		}
		
    if Application.use_edit_disance?
    		threads[4] = Thread.new {
  		  start_time = Time.now
  		  Thread.current[:name] = "edit"
  			@ed = EditDistance.new(query)
  			distances = @ed.match(@ed.all_solutions)
  			@ed_candidates = @ed.combine(distances) # Combine candidates & their edit distances
        Tester.finalize_thread(start_time)
  		}
  	end
				
		threads.each do |aThread| 
		  aThread.join
	  end
	end
	
	def self.finalize_thread start_time
	 	Log.to_term "\t#{Thread.current[:name]} finished in #{ "%0.2f" % (Time.now - start_time)} seconds"
	end	
end