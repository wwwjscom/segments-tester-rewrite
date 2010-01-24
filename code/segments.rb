require "code/sql"

class Segments < Application
	
	def find(query)
		candidates = {}

    Log.seg("Method 1")
		segs 	= method_1(query)
		cans_1 	= find_candidates(segs)
    Log.seg("Method 3")
		segs 	= method_3(query)
		cans_3 	= find_candidates(segs)

    candidates = merge_candidates(cans_1, cans_3)

    Log.seg("Method 4")
		segs 	= method_4(query)
		cans_4 	= find_candidates(segs)

    candidates = merge_candidates(candidates, cans_4)

    Log.seg("Method 5")
		segs 	= method_5(query)
		cans_5 	= find_candidates(segs)

    candidates = merge_candidates(candidates, cans_5)

    Log.seg("Method 6")
		segs 	= method_6(query)
		cans_6 	= find_candidates(segs)

    candidates = merge_candidates(candidates, cans_6)

    Log.seg("Method 7")
		segs 	= method_7(query)
		cans_7 	= find_candidates(segs)

    candidates = merge_candidates(candidates, cans_7)
	end
	
	
#	private # ----------------
	
	def merge_candidates(hsh1, hsh2)
		hsh1.merge(hsh2) { |key, oldval, newval| key = oldval + newval }
	end
	
	def find_candidates(segments)
		weight = 1.0
        @sql = SQL.new
        @candidates = {}
        segments.each do |seg|
	        query = "SELECT * FROM #{get_db}.queries_misspelled WHERE LCASE(solution) LIKE LCASE('#{seg}')"
	        results = @sql.query(query)
	        Log.seg(query)

            #p results.fetch_hash
			while row = results.fetch_hash
		        solution = row["solution"]
		        if @candidates.has_key?(solution)
					@candidates[solution] += 1.0*weight
				else
					@candidates[solution] = 1.0*weight
				end # if
			end # while
			weight = weight # Rought estimate show that using weights doesn't imrpove rank...go figure.
		end # each
	@candidates
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
		while q.size >= 3 do
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
		while @length >= 3 do
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
    Log.seg("Method 4 given: #{query}")
		query = ["%" + query[(query.length/2)..-1]]
    Log.seg("Method 4 yields: #{query}")
    query
	end
	
	
	# Same as above function, but keeps the latter 1/2 of the query.
	# However, a percent SHOULD be put at the end of the query and NOT
	# at the begining of the query.
	# Example:
	# %Slovakia%
	# Slov%
	def method_5(query)
		query = [query[0..(query.length/2)-1] + "%"]
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
		query = [query[0..1] + "%" + query[-2..-1]]
	end
end
