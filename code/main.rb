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
		
		# Declare stats instance variables here, since we'll be adding
		# to them over the life of the program
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
			@eval_3grams = Evaluator.new(@t.grams_3_candidates, solution)
			p @eval_3grams.found?
			p @eval_3grams.rank
			
			p @t.grams_4_candidates
			p @t.dm_candidates
			
			p @t.seg_candidates
			@eval_seg = Evaluator.new(@t.seg_candidates, solution)
			p @eval_seg.found?
			p @eval_seg.rank
			
			# Segments failed to meet the threshold, and is lower than 3grams,
			# so use the 3grams results for segments.
			if Evaluator.compare_confidence(@eval_seg, @eval_3grams) == "e2"
				@eval_seg = @eval_3grams
			end
			
			
			# ...
		end
	end
	
end