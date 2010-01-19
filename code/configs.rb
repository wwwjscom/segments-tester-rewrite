require 'yaml'

class Configs
	# Read in the config.yml file, and also add the SEG_ENV
	# environment variable to the configs hash
	def self.read_yml
		hash = YAML.load_file('config.yml')
		hash["SEG_ENV"] = ENV["SEG_ENV"]
		hash
	end
end