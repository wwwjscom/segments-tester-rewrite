require 'yaml'
require "code/sql"
require "code/configs"
require "code/tester"
require "code/application"
require "code/evaluator"
require "code/stats"

class Main < Application
	
	attr_reader :config
	
	def initialize
		@config 	= Configs.read_yml
		@sql		= SQL.new
		@s_3grams 	= Stats.new('3grams')
		@s_4grams 	= Stats.new('4grams')
		@s_dm 		= Stats.new('DM Soundex')
		@s_seg	 	= Stats.new('Segments')
		
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
			
			@eval_3grams 	= Evaluator.new(@t.grams_3_candidates, solution)
			@eval_4grams 	= Evaluator.new(@t.grams_4_candidates, solution)
			@eval_dm 		= Evaluator.new(@t.dm_candidates, solution)
			@eval_seg 		= Evaluator.new(@t.seg_candidates, solution)
			
			# Segments failed to meet the threshold, and is lower than 3grams,
			# so use the 3grams results for segments.
			if Evaluator.compare_confidence(@eval_seg, @eval_3grams) == "e2"
				@eval_seg = @eval_3grams
			end
		
			# Add to the stats instance variables
			@s_3grams.add(@eval_3grams)
			@s_4grams.add(@eval_4grams)
			@s_dm.add(@eval_dm)
			@s_seg.add(@eval_seg)
			
			#debug(misspelled)			
			
			# ...
		end
		
		# Done adding results, calculate stats
		@s_3grams.calculate
		@s_4grams.calculate
		@s_dm.calculate
		@s_seg.calculate
		
		# Display the results
		puts @s_3grams.to_s
		puts @s_4grams.to_s
		puts @s_dm.to_s
		puts @s_seg.to_s
	end
	
	def debug(misspelled)
		p '-'*50
		
		p misspelled
		
		p '3grams'
		p @t.grams_3_candidates
		p @eval_3grams.found?
		p @eval_3grams.rank if @eval_3grams.found?
		
		p '4grams'
		p @t.grams_4_candidates
		p @eval_4grams.found?
		p @eval_4grams.rank if @eval_4grams.found?
		
		p 'dm'
		p @t.dm_candidates
		p @eval_dm.found?
		p @eval_dm.rank if @eval_dm.found?
		
		p 'seg'
		p @t.seg_candidates
		p @eval_seg.found?
		p @eval_seg.rank if @eval_seg.found?
	end
	
end