#require "code/ngram"

class Tester
	

	
	# Queries all of our engines for the given query
	def find
		NGram.find(3, query)
		# ...
	end	
end