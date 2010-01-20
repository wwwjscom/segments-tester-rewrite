require 'yaml'
require "code/sql"
require "code/configs"
require "code/tester"
require "code/application"
require "code/evaluator"

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
			solution 	= attrs["solution"]
			misspelled 	= attrs["misspelled"]
			
			@t = Tester.new
			@t.find(misspelled)
			
			p misspelled
			
			p @t.grams_3_candidates
			@eval_grams_3 = Evaluator.new(@t.grams_3_candidates, solution)
			p @eval_grams_3.found?
			p @eval_grams_3.rank
			
			p @t.grams_4_candidates
			p @t.dm_candidates
			
			p @t.seg_candidates
			@eval_seg = Evaluator.new(@t.seg_candidates, solution)
			p @eval_seg.found?
			p @eval_seg.rank
			
			# ...
		end
	end
	
end