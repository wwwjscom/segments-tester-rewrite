require_relative "evaluator"

class Stats < Application
	
	attr :founds
	attr_accessor :name
	
	# Pass in the engine's name
	def initialize(name)
		@name 			= name
		@total_searches = 0
		@total_found	= 0
		@found_percent 	= 0.0
		@average_rank	= 0.0
		@average_rank_a	= []
		@founds			= {} # Key of the solution, value of its rank.
	end
	
	def add(eval)
		@total_searches += 1
		results = eval.found_and_rank
		Log.term "[#{@name}] Results hash: #{results.to_s}", 'DEBUG'
		found = results[:found]
		if found
  		rank = results[:rank]
			@founds[eval.solution] = rank
			@total_found += 1
			@average_rank_a << rank
			Log.term @name, 'DEBUG'
			Log.term rank, 'DEBUG'
		end
	end
	
	# Perform calculations when we're done adding results
	def calculate
		average_rank
		found_percent
	end
	
	def average_rank
		@rank = 0.0
		Log.term "#{@name}", 'DEBUG'
		Log.term @average_rank_a.to_s, 'DEBUG'
		@average_rank_a.each do |r|
			begin
				@rank += r
			rescue
				p "rank is nil..."
			end
		end
		@average_rank = ("%.2f" % (@rank.to_f/@total_found.to_f)).to_f
	end
	
	def found_percent
		@found_percent = ("%.2f" % ((@total_found.to_f/@total_searches.to_f)*100)).to_f
	end

	def to_s
		s = "#{@name} found #{@total_found}/#{@total_searches}: #{@found_percent}% with an average rank of #{@average_rank}"
		s += " and a common rank of #{@common_rank}" if @name =~ /segment/i or @name =~ /3grams/i
		s
	end
	
	def common_rank(other_engine)
		@common_rank = 0.0
		other_engine.founds.each_key do |key|
#			puts "key: #{key}"
#			puts "founds[key]: #{@founds[key]}"
			begin
				@common_rank += @founds[key]
			rescue
				Log.app "#{other_engine.name} found one #{self.name} did not find!  Solution: #{key}", "WARN"
				Log.to_term "#{other_engine.name} found one #{self.name} did not find!  Solution: #{key}", "WARN"
			end
		end
		@common_rank = @common_rank/other_engine.founds.size
	end
end