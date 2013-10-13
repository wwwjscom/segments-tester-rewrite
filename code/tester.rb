require_relative "application"
require_relative "ngram"
require_relative "segments"
require_relative "dm_soundex"
require_relative "edit_distance"

class Tester < Application
	
	attr_accessor :grams_3_candidates, :grams_4_candidates, :dm_candidates, :seg_candidates, :ed_candidates
	
	# Queries all of our engines for the given query
	def find(query, bigram_query = false)
		
		threads = []
		
		threads[0] = Thread.new {
		  start_time = Time.now
		  Thread.current[:name] = "3grams"
			@grams_3 = Ngram.new(3, query, bigram_query)
			@grams_3_candidates = @grams_3.find
			Tester.finalize_thread(start_time)
		}
				
		threads[1] = Thread.new {
		  start_time = Time.now
		  Thread.current[:name] = "seg"
			@seg = Segments.new
			@seg_candidates = @seg.find(query, bigram_query)
			Tester.finalize_thread(start_time)
		}
		
		threads.each do |aThread| 
		  aThread.join
	  end
	end
	
	def self.finalize_thread start_time
		ActiveRecord::Base.connection.close
	 	Log.to_term "\t#{Thread.current[:name]} finished in #{ "%0.2f" % (Time.now - start_time)} seconds", "DEBUG"
	end	
end
