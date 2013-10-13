#require "mysql"
require_relative "configs"
require_relative "application"
require_relative "candidates"

class Queries3grams < ActiveRecord::Base
	self.table_name = "queries_3grams"	
end

class Queries4grams < ActiveRecord::Base
	self.table_name = "queries_4grams"
end


class Ngram < Application

	attr_accessor :grams, :query

	# Generates the ngrams from the query and stores them for later access
	def initialize(n, query, bigram_query = false)
	  @bigram_query = bigram_query
		@candidates = Candidates.new
		@misspelled = query
		@query = query
		@grams = [] # Array containing all of the grams generated
		@n = n

		(0..query.length).map do |index|
			q = query[index, n]
			unless q.length < 2
				gram = query[index, n]
				@grams << gram unless gram.length < n
			end
		end
	end

	# Searches for query using a gram of size n
	# Retuns a list of candidates
	def find
		@config = Configs.read_yml
		@sql = SQL.new
		@grams.each do |gram|
		  
		  if @bigram_query
		    query   = "SELECT * FROM #{get_db}.lexicon_bigrams WHERE LCASE(word) LIKE LCASE('%#{gram}%') AND count > 90 ORDER BY count DESC LIMIT 10"
  		else
  		  query   = "SELECT * FROM #{get_db}.wikipedia_words WHERE LCASE(word) LIKE LCASE('%#{gram}%') AND count > 500 ORDER BY count DESC LIMIT 10"
		  end
      results = Queries3grams.find_by_sql(query)
      
			results.each do |result|
				add(result)
			end
			
		end
		@candidates
	end
	
	def add(row)
		solution   = row['word']
		id         = row['id']
		misspelled = @misspelled

		if @candidates.has_id?(id)
			@candidates.vote_for(id, 1.0)
		else
			c = Candidate.new(misspelled, solution, id)
			@candidates.add(c)
		end # if
	end

end
