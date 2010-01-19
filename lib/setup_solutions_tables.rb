require "code/configs"
require "code/ngram"
require "code/sql"
require "code/application"

class SetupSolutionsTables < Application

	attr_accessor :ngram_objs

	def initialize
		@config = Configs.read_yml
		read_file
	end

	def read_file
		@lines_index = 0
		@lines = []
		file = (@config['SEG_ENV'] =~ /test/i) ? 'db/solutions_rspec.csv' : 'db/solutions.csv'
		file = File.open(file)
		while line = file.gets do
			@lines << line
		end
	end
	
	def has_next?
		@lines_index < @lines.size
	end
	
	def next
		@lines_index += 1
		@lines[@lines_index-1].chomp
	end
	
	# Drops the given table from the db
	def drop_table(table_suffix = nil)
		sql = SQL.new
		sql.query "DROP TABLE IF EXISTS #{@config['queries_table']}#{table_suffix}"
	end

	# Generates the ngrams from the solutions prior to inserting them
	def generate_ngrams(n)
		@ngram_objs = [] # Holds a bunch of ngram objects
		@lines.each do |line|
			query = parse(line)[:mispelled]
			@ngram_objs << Ngram.new(n, query)
		end
	end
	
	# Loops over the gram objects and calls insert on each
	def insert_ngrams(n)
		type = (n == 3) ? "_3grams" : "_4grams"
		@ngram_objs.each do |obj|
			obj.grams.each do |gram|
				insert(type, gram, obj.query)
			end
		end
	end
	
	# Inserts a set of data into the correct table
	def insert(type, type_attr, solution)
		sql = SQL.new
		sql.query "CREATE TABLE IF NOT EXISTS #{@config['queries_table']}#{type} (`#{type.gsub('_', '')}` VARCHAR(255) NOT NULL, `solution` VARCHAR(255) NOT NULL)"
		sql.query "INSERT INTO #{@config['queries_table']}#{type} VALUES ('#{type_attr}', '#{solution}')"
	end
	
	# Parses the line and returns a hash of its contents
	def parse(line)
		hash = { :mispelled => line.split(',')[0], :solution => line.split(',')[1] }
	end
end