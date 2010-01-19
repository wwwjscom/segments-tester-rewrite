require 'yaml'
require "code/sql"
require "code/configs"
require "code/tester"

class Main
	
	attr_reader :config
	
	def initialize
		@config = Configs.read_yml
		db		= (@config["SEG_ENV"] =~ /test/i) ? @config["db_test_db"] : @config["db_db"] # use the right db
		@sql	= SQL.new(@config["db_user"], @config["db_pass"], db)
	end
	
	def run
		@sql.populate(@config) # setup function
		while @sql.has_next?
			attrs = @sql.next
			results = Tester.find(attrs["query"])
			# ...
		end
	end
	
end