require "tempfile"

class DMSoundex

	attr_reader :query, :encoding

	def initialize(query)
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
	
end