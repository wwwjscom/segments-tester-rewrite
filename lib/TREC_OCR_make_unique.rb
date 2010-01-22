# Reads the solutions.csv file and makes it unique (only need to run this when running one of the TREC OCT files)

@lines = []
file = File.open('db/solutions.csv')
while line = file.gets
	@lines << line.chomp
end
file.close

@lines.uniq!

file = File.open('db/solutions.csv', 'w')
(0..@lines.length-1).each do |i|
	file.puts @lines[i]
end
file.close