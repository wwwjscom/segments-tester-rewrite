require 'yaml'
require "code/sql"
require "code/config"

class Main
	
	attr_reader :config
	
	def initialize
		@config = Config.read_yml
		@sql	= SQL.new(@config["db_user"], @config["db_pass"], @config["db_db"])
	end
	
	def run
		while @sql.has_next?
			# ...
		end
	end
	
end