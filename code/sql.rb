require 'mysql'

class SQL
	
	attr_reader :user, :pass, :database
	
	def initialize(user, pass, db, testing = false)
		@user		= user
		@pass		= pass
		@database	= db
		@testing	= testing
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