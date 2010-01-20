class Segments
	
	def self.find(query)
		@candidates = {}
		`php lib/segments/searchresults.php "#{query}"`
		file = File.open('tmp/our_results.txt')
		while line = file.gets do
			line.chomp!
			votes = line.split(', ')[0].to_i
			condidate = line.split(', ')[1]
			@candidates[condidate] = votes
		end
		@candidates
	end
	
end