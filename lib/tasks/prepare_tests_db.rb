require "code/sql"
#require "code/config"

class PrepareTestsDb
	
	def initialize
		#@config = Config.read_yml
		#@mysql = Mysql.new(@config["db_user"], @config["db_pass"], @config["db_db"])
		@mysql = SQL.new('root', 'root', 'segments_1234')
	end
	
	def setup
		@mysql.query("DROP database `segments_1234`;")
		@mysql.query("CREATE DATABASE `segments_1234`;")
	end
end