require "code/configs"

class Stats

	def initialize
		@config = Configs.read_yml
		file_name = @config['input_file']
		@solutions = []
		File.open(file_name) do |file|
			file.lines.each { |l| @solutions << l.split(',')[0] }
		end
		create_length_array
	end

	def count
		@solutions.size.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
	end

	def avg_query_length
		"%.2f" % (@solutions_by_length.inject(:+).to_f / @solutions_by_length.size)
	end

	def min_query_length
		@solutions_by_length.min
	end

	def max_query_length
		@solutions_by_length.max
	end

	def median_query_length
		@solutions_by_length.sort[@solutions_by_length.size/2]
	end

	def mode_query_length
		sorted = @solutions_by_length.sort
		a = Array.new
		b = Array.new
		sorted.each do |x|
			if a.index(x)==nil
				a << x # Add to list of values
				b << 1 # Add to list of frequencies
			else
				b[a.index(x)] += 1 # Increment existing counter
			end
		end
		maxval = b.max           # Find highest count
		where = b.index(maxval)  # Find index of highest count
		a[where]                 # Find corresponding data value
	end


	private
	def create_length_array
		@solutions_by_length = []
		@solutions.each {|s| @solutions_by_length << s.length}
	end
end
