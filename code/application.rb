require "code/configs"

class Application

	SEG_ENV = Configs.read_yml['SEG_ENV']
	
	# Returns the db to be used based on our enviornment
	def get_db
		@config = Configs.read_yml
		(SEG_ENV =~ /test/i) ? @config['db_test_db'] : @config['db_db']
	end


	# Takes in the matches and returns a hash of candidates and votes
	# Should be depreated...but see comment below
	def organize_votes(matches)
		@hash = {}
		matches.flatten!
		keys = matches.uniq # uniq?? Shouldn't we consider multiple matches as more votes...
		keys.each do |key|
			@hash[key.chomp] = matches.count(key)
		end
		@hash
	end

	class Log
		
		# Logs a msg to the status file
		def self.stats(msg)
			f = File.open('logs/stats.log', 'a')
			f.puts msg
			f.close			
		end
		
		# Logs a msg to the application log
		def self.app(msg)
			f = File.open('logs/application.log', 'a')
			f.puts msg
			f.close
		end

		# Log a msg to the segments log
		def self.seg(msg)
			f = File.open('logs/segments.log', 'a')
			f.puts msg
			f.close
		end
		
		def self.ed(msg)
			f = File.open('logs/edit_distance.log', 'a')
			f.puts msg
			f.close
		end

		# Deletes all logs
		def self.clear
			Dir.glob('logs/*.log').each do |e| 
				File.delete(e)
			end
		end
	end

end