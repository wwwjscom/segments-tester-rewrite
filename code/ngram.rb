require "mysql"
require "code/configs"

class Ngram

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
	def find
		@config = Configs.read_yml
		@sql = SQL.new
		@matches = []
		@grams.each do |gram|
			results = @sql.query "SELECT solution FROM #{@config['queries_table']}_#{@n}grams WHERE LCASE(#{@n}grams) = LCASE('#{gram}')"
			if results.class == Array
				@matches << results				
			else
				while r = results.fetch_hash do
					@matches << r
				end
			end
		end
		@matches
	end
end