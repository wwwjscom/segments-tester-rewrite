require_relative "sql"
require_relative "candidates"

class QueriesSegments < ActiveRecord::Base
	self.table_name = "wikipedia_words"
end

class Segments < Application

	def initialize
		@candidates = Candidates.new
	end

	def find(query)
		@misspelled = query
        
		Log.seg("Method 1", "DEBUG")
		segs = method_1(query)
		find_candidates(segs)
		
		Log.seg("Method 3", "DEBUG")
		segs = method_3(query)
		find_candidates(segs)

		Log.seg("Method 4", "DEBUG")
		segs = method_4(query)
		find_candidates(segs)

		Log.seg("Method 5", "DEBUG")
		segs = method_5(query)
		find_candidates(segs)

		Log.seg("Method 6", "DEBUG")
		segs = method_6(query)
		find_candidates(segs)

		Log.seg("Method 7", "DEBUG")
		segs = method_7(query)
		find_candidates(segs)

		@candidates
	end


	#	private # ----------------

	def find_candidates(segments)
		@sql = SQL.new

		segments.each do |seg|
			query   = "SELECT * FROM #{get_db}.wikipedia_words WHERE LCASE(word) LIKE LCASE('#{seg}') ORDER BY count DESC LIMIT 10"
			#puts query
			results = QueriesSegments.find_by_sql(query)
			results.each do |result|

				solution = result["word"]
				id			 = result["id"]  		  
				if @candidates.has_id?(id)
					@candidates.vote_for(id, 1.0)
				else
					c = Candidate.new(@misspelled, solution, id)
					@candidates.add(c)
				end # if				
			end

		end # each
	end


	# This function cuts off one letter at a time from the start and end of the search term...
	# It then re-searches using the new term.  It continues to do so until the ET is reached,
	# Or the term has become too small to cut off more letters.
	# Example:
	# %Slovakia%
	# %lovaki%
	# %ovak%
	# etc
	def method_1(query)
		q = String.new(query)
		@segments = []
		while q.size > 3 do
			q = q[1..-2]
			@segments << "%" + q + "%"
		end
		@segments
	end

	# This function replaces the middle of the search term with %'s
	# MySQL views %'s "match anything".  The function then re-searches
	# The database using the new query until either the ET is reached,
	# Or until the query is too short to continue dividing.
	# Example:
	# %Slovakia%
	# %Slov%kia%
	# %Slo%ia%
	# etc
	def method_3(query)
		q = String.new(query)
		@segments =  []
		@length = q.length
		while @length > 3 do
			q.gsub!('%', '')
			q[@length/2] = '%'
			@length = q.length
			@segments << String.new(q)
		end
		@segments
	end


	# This function divides the query in 1/2 and cuts off the front 1/2.
	# It only adds %'s to the BEGINING of the word.
	# Exmaple:
	# %Slovakia%
	# %akia
	def method_4(query)
	  if query.length == 1
      return [query]
    else
  		Log.seg("Method 4 given: #{query}", "DEBUG")
  		query = ["%" + query[(query.length/2)..-1]]
  		Log.seg("Method 4 yields: #{query}", "DEBUG")
  		return query
  	end
	end


	# Same as above function, but keeps the latter 1/2 of the query.
	# However, a percent SHOULD be put at the end of the query and NOT
	# at the begining of the query.
	# Example:
	# %Slovakia%
	# Slov%
	def method_5(query)
	  if query.length == 1
      return [query]
    else
  		return [query[0..(query.length/2)-1] + "%"]
		end
	end


	# This function cuts everything out of the middle of the query...
	# Only leaving the first and last letters.  It replaces the
	# chars in the middle of the query wiht a %.
	# Example:
	# Slovakia
	# S%a
	def method_6(query)
		query = [query[0].chr + "%" + query[-1].chr]
	end

	# Same as above, but it keeps the last two AND first two
	# chars of the query.
	# Example:
	# Slovakia
	# Sl%ia
	def method_7(query)
    if query.length == 1
      return [query]
    else
  		return [query[0..1] + "%" + query[-2..-1]]
		end
	end
end
