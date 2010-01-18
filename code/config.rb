require 'yaml'

class Config
	def self.read_yml
		YAML.load_file('config.yml')
	end
end