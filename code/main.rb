require 'yaml'
require "code/sql"


class Main
	
	attr_reader :config
	
	def initialize
		@config = YAML.load_file('config.yml')
		@sql	= SQL.new(@config["db_user"], @config["db_pass"], @config["db_db"])
	end
	
end