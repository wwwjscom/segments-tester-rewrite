require "code/configs"

class Application
	
	# Returns the db to be used based on our enviornment
	def get_db
		@config = Configs.read_yml
		(@config['SEG_ENV'] =~ /test/i) ? @config['db_test_db'] : @config['db_db']
	end
	
	
	# Takes in the matches and returns a hash of candidates and votes
	def organize_votes(matches)
		@hash = {}
		matches.flatten!
		keys = matches.uniq
		keys.each do |key|
			@hash[key.chomp] = matches.count(key)
		end
		@hash
	end

  class Log
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

    # Deletes all logs
    def self.clear
      Dir.glob('logs/*.log').each do |e| 
        File.delete(e)
      end
    end
  end
	
end
