require 'mysql'

class SQL
	
	attr_reader :user, :pass, :database, :queries
	
	def initialize(user, pass, db, testing = false)
		@user		= user
		@pass		= pass
		@database	= db
		@testing	= testing
	end

	# Initializes the queries array so we can call
	# functions like has_next? and others.
	def populate(config)
		@queries_index = 0 # tracks our location within the queries array
		@queries = []
		results = query("SELECT * FROM #{config['queries_table']};")
		while r = results.fetch_hash
			@queries << r
		end
	end
	
	def has_next?
		@queries_index <= @queries.size
	end
	
	def next
		# return next hash...
		@queries_index += 1
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