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
			@t = Tester.new
			@t.find(attrs["misspelled"])
			
			p attrs["misspelled"]
			p @t.grams_3_candidates
			p @t.grams_4_candidates
			p @t.dm_candidates
			p @t.seg_candidates
			
			# ...
		end
	end
	
end