require "code/configs"

class Application
	
	# Returns the db to be used based on our enviornment
	def get_db
		@config = Configs.read_yml
		(@config['SEG_ENV'] =~ /test/i) ? @config['db_test_db'] : @config['db_db']
	end
end