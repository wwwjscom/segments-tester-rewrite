#require 'mysql'
require "code/application"
require "code/queries"

class QueriesMisspelled < ActiveRecord::Base
	set_table_name "queries_misspelled"
end

class SQL < Application
	
	attr_reader :user, :pass, :database, :queries
	
	def initialize(user = Configs.read_yml["db_user"], pass = Configs.read_yml["db_pass"], db = get_db, testing = false)
		@user		= user
		@pass		= pass
		@database	= db
		@testing	= testing
	end

	# Initializes the queries array so we can call
	# functions like has_next? and others.
	def populate(config = nil)
		@queries_index = 0 # tracks our location within the queries array
		@queries = []
		#results = query("SELECT * FROM #{@config['queries_table']}_misspelled;")
		results = QueriesMisspelled.find_by_sql "SELECT * FROM #{@config['queries_table']}_misspelled;"
		
		results.each do |r|
			@queries << r
		end
		
#		while r = results.fetch_hash
#			@queries << r
#		end
	end
	
	def to_queries
	  queries = Queries.new
		while has_next?
			attrs = self.next
			solution_id = attrs["id"]
			solution    = attrs["solution"]
			misspelled  = attrs["misspelled"]
			queries << Query.new(solution_id, solution, misspelled)
		end
		queries
	end
	
	def has_next?
		@queries_index < @queries.size
	end
	
	# return next hash...
	def next
		@queries_index += 1
		@queries[@queries_index-1]
	end

	# Drops the given table from the db
	def self.drop_table(table_suffix = nil)
		@config = Configs.read_yml
		sql = self.new
		sql.query "DROP TABLE IF EXISTS #{@config['queries_table']}#{table_suffix}"
	end

	# Abstract query function
	def query(q)
		_query(q)
	end


	#------ private methods


	def _query(q)
		ret = []
		begin
			db = Mysql.real_connect('localhost', @user, @pass, @database)
			ret = db.query(q)
			rescue Mysql::Error => e
				unless @testing
					puts "Error code: #{e.errno}"
					puts "Error message: #{e.error}"
					puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
				end
			ensure
				# disconnect from server
				db.close if db
		end
		ret
	end

	
end