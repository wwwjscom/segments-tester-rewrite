require "tempfile"
require "code/configs"
require "code/application"


class DMSoundex < Application

	attr_reader :query, :encoding

	def initialize(query)
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
		@matches = []
		sql = SQL.new
		results = sql.query "SELECT solution FROM #{@config['queries_table']}_dm_soundex WHERE dmsoundex = #{@encoding}"
		unless results.num_rows == 1
			while r = results.fetch_row
				@matches << r
			end
		end
		@matches
		organize_votes(@matches)
	end
end