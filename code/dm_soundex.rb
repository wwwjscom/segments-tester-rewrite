require "tempfile"
require "code/configs"
require "code/application"
require "code/candidates"

class DMSoundex < Application

	attr_reader :query, :encoding

	def initialize(query)
		@misspelled = query
		@candidates = Candidates.new
		@config = Configs.read_yml
		@query = query
		encode(@query)
	end

	# Generates the encoding of the given query and ...returns it.
	def encode(query)
		file = Tempfile.new('dm_soundex') # generate a tmp file
		`perl lib/dm-soundex.pl "#{query}" > #{file.path}` # encode using the perl program
		f = File.open(file.path) # open the temp file
		@encoding = f.gets.chomp! # store the encoding
		f.close # stop reading the temp file
		file.close! # unlinks the temp file
	end

	def find
		sql = SQL.new
		results = sql.query "SELECT * FROM #{get_db}.#{@config['queries_table']}_dm_soundex WHERE dmsoundex = '#{@encoding}'"
		if results.class == Array
			add(results.fetch_hash)
		else
			while r = results.fetch_hash do
				add(r)
			end
		end
		
		@candidates
	end
	
	def add(row)		
		solution   = row["solution"]
		id         = row['id']
		misspelled = @misspelled
		
		if @candidates.has_id?(id)
			@candidates.vote_for(id, 1.0)
		else
			c = Candidate.new(misspelled, solution, id, 1.0)
			@candidates.add(c)
		end # if
	end
	
end