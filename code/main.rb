require 'yaml'
require "code/sql"
require "code/configs"
require "code/tester"
require "code/application"

class Main < Application
	
	attr_reader :config
	
	def initialize
		@config = Configs.read_yml
		@sql	= SQL.new
	end
	
	def run
		@sql.populate(@config) # setup function
		while @sql.has_next?
			attrs = @sql.next
			#results = Tester.find(attrs["query"]) -- todo after setup rake tasks are complete
			# ...
		end
	end
	
end