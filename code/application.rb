require 'rubygems'
require 'active_record'

require_relative "configs"

# FIXME: Why the fuck doesn't this read the config values?
ActiveRecord::Base.establish_connection(
	:adapter=> "mysql2",
	:host => "localhost",
	:database=> "segments_1234",
	:username => "root",
	:password => "",
	:pool => 30,
	:wait_timeout => 10
)


class Application

	SEG_ENV = Configs.read_yml['SEG_ENV']
	@@config = nil
	
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
	
	def self.use_edit_disance?(config = nil)
	  config = Configs.read_yml if config == nil
	  config["use_edit_distance"]
	end
	
	def self.get_config
   @@config = Configs.read_yml if @@config == nil
   @@config
	end
	
	class Log
	  
	  LOG_LEVELS = ["ERROR", "WARN", "INFO", "DEBUG"]
	  
	  def self.log_msg?(level)
	    allow_index = LOG_LEVELS.index(Application.get_config["log_level"])
	    level_index = LOG_LEVELS.index(level)
	    (level_index > allow_index) ? true : false
    end
		
		# Log intermediate stats
		def self.intermediary_stats(msg, level = "INFO")
		  return if self.log_msg?(level)
			f = File.open('logs/intermediary_stats.log', 'a')
			f.puts Log.format_msg(msg, level)
			f.close
		end
		
		# Logs a msg to the status file
		def self.stats(msg, level = "INFO")
		  return if self.log_msg?(level)
			f = File.open('logs/stats.txt', 'a')
			f.puts Log.format_msg(msg, level)
			f.close			
		end
		
		# Logs a msg to the application log
		def self.app(msg, level = "INFO")
		  return if self.log_msg?(level)
			f = File.open('logs/application.log', 'a')
			f.puts Log.format_msg(msg, level)
			f.close
		end

		# Log a msg to the segments log
		def self.seg(msg, level = "INFO")
		  return if self.log_msg?(level)
			f = File.open('logs/segments.log', 'a')
			f.puts Log.format_msg(msg, level)
			f.close
		end
		
		def self.ed(msg, level = "INFO")
		  return if self.log_msg?(level)
			f = File.open('logs/edit_distance.log', 'a')
			f.puts Log.format_msg(msg, level)
			f.close
		end

		# Puts a msgs to the terminal (but also to a log file, go figure!)
		def self.to_term msg, level = "INFO"
		  self.term msg, level
		end
		
		def self.term msg, level = 'INFO'
		  return if self.log_msg?(level)
		  puts Log.format_msg msg, level
		  f = File.open('logs/terminal.log', 'a')
		  f.puts Log.format_msg(msg, level)
			f.close
		end

		# Deletes all logs
		def self.clear
			Dir.glob('logs/*.log').each do |e| 
				File.delete(e)
			end
		end
		
		def self.format_msg msg, level
		  "#{Log.date_time} [#{level}]:: #{msg}"
		end
		
		def self.date_time
		  "#{Time.now.strftime("%m-%d-%y %H:%M:%S")}"
		end
	end

end
