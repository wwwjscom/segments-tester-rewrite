require "mysql"
require "code/configs"
require "code/application"
require "code/candidates"

class Ngram < Application

	attr_accessor :grams, :query

	# Generates the ngrams from the query and stores them for later access
	def initialize(n, query)
		@query = query
		@grams = [] # Array containing all of the grams generated
		@n = n

		(0..query.length).map do |index|
			q = query[index, n]
			unless q.length < 2
				@grams << query[index, n]
			end
		end
	end

	# Searches for query using a gram of size n
	# Retuns a list of candidates
	def find
		@config = Configs.read_yml
		@sql = SQL.new
		@candidates = Candidates.new
		@grams.each do |gram|
			results = @sql.query "SELECT * FROM #{@config['queries_table']}_#{@n}grams WHERE LCASE(#{@n}grams) = LCASE('#{gram}')"
			if results.class == Array
				id         = results["id"]
				solution   = results["solution"]
				misspelled = results["misspelled"]

				@candidates.add Candidate.new(misspelled, solution, id)
			else
				while r = results.fetch_row do
					p r
					id         = r["id"]
					solution   = r["solution"]
					misspelled = r["misspelled"]

					@candidates.add Candidate.new(misspelled, solution, id)
				end
			end
		end
	end

end