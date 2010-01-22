class TRECOCRParser
	
	def skip_if(line)
		return true if line =~ /<\/?DOC(NO)?>/i
		return true if line =~ /<\/?TEXT>/i
		return true if line =~ /<\/?PARENT>/i
		return true if line =~ /<\/?AGENCY>/i
		return true if line =~ /<\/?ACTION>/i		
		return true if line =~ /<\/?SUMMARY>/i
#		return true if line =~ /<\/?CFRNO>/i
		return true if line =~ /<\/?DATE>/i
		return true if line =~ /<\/?SUPPLEM>/i
		return true if line =~ /<\/?SIGNER>/i
		return true if line =~ /<\/?SIGNJOB>/i
		return true if line =~ /<\/?frfiling>/i
		return true if line =~ /<\/?billing>/i
		return true if line =~ /<\/?table>/i
		return true if line =~ /<\/?address>/i
		return true if line =~ /<\/?further>/i
		
		
		return true if line[/pjg/]
		return true if line == ''
		return true if line == ' '		
	end

	def sub(line)
		# Bad tags
		line.gsub!(/<\/?USDEPT>/i, '')
		line.gsub!(/<\/?USBUREAU>/i, '')
		line.gsub!(/<\/?CFRNO>/i, '')
		line.gsub!(/<\/?RINDOCK>/i, '')
		line.gsub!(/<\/?doctitle>/i, '')
		

		# Bad symbols
#		line.gsub!('mjds', '')
#		line.gsub!(/^m$/, '')
#		line.gsub!(/ls/, '')
		line.gsub!(/<\w+>/, '')
		line.gsub!(/&blank;/, '')
		line.gsub!(/[!\.\/\,`'_\[\]:<>\-()]/, ' ')
		line.gsub!('&hyph;', ' ')
		line.gsub!('&amp;', '')
		
		line
	end
	
	def read_source
		file = File.open('/Users/wwwjscom/Downloads/confusion_track/original/01/fr940104.0')
		i = 0
		@doc_lines = []
		while line = file.gets.chomp.downcase

			next if skip_if(line)
			sub(line)


			line =  line.chomp.downcase
			line.split(' ').each do |l|
				if @force_skip_origin.include?(i)
					# skip
				else
					@doc_lines << l
				end
				i += 1
			end


			break if i > @max_lines
		end
		file.close
	end
	
	def read_degraded
		@degraded_lines = []
		file = File.open('/Users/wwwjscom/Downloads/confusion_track/degrade20/01/FR940104.0')

		i = 0
		while line = file.gets.strip
			line.gsub!(/<.+>/, '')

			next if skip_if(line)
			sub(line)

			line = line.chomp.downcase
			line.split(' ').each do |l|
				
				if @force_skip_degraded.include?(i)
					# skip
				else
					@degraded_lines << l
				end				
				i += 1
			end

			break if i > @max_lines
		end
		file.close
	end
	
	def bad_queries(orig_query, deg_query, i)
		# skip if the potential query is too short
		if @doc_lines[i].length <= 3 || @degraded_lines[i].length <= 3
			return true
		end

		# Skip if we've seen the query already (in the orig doc)
		if @used.include?(orig_query)
			return true
		else
			@used << orig_query
		end
		
		# Skip if numeric only
		if orig_query =~ /\d+/
			return true
		end
		
		# Skip if its an exact match
		if orig_query == deg_query
			return true
		end
		
		if orig_query[0..5].include?('j') || deg_query[0..5].include?('j')
			return true
		end
	end
	
	
	def print_files
		@total = 0
		@used = []
		orig_offset	= @force_skip_origin.size
		deg_offset 	= @force_skip_degraded.size
#		deg_offset 	= @force_skip_degraded.size - @force_skip_origin.size+1
		(0..@degraded_lines.size-1).each do |i|
			orig_query 	= @doc_lines[i]
			deg_query	= @degraded_lines[i]
			
			if ARGV[1] != nil
				next if bad_queries(orig_query, deg_query, i)
			end
			
			puts "#{i}\t#{i+orig_offset}\t#{@doc_lines[i].center(20)} \t\t#{i+deg_offset}\t#{@degraded_lines[i]}"
			@out_file.puts "#{@degraded_lines[i]},#{@doc_lines[i]}"
			@total += 1
		end
		p @total
		puts "Offset: #{orig_offset}, #{deg_offset}"
	end
	
	def main
		read_source
		read_degraded
		@out_file = File.open('tmp/ocr.csv', 'w')
		print_files
		@out_file.close
	end
	
	def initialize(max_lines, force_skip_degraded, force_skip_origin)
		@max_lines 				= max_lines		
		@force_skip_degraded 	= force_skip_degraded
		@force_skip_origin		= force_skip_origin
	end
end


force_skip_origin	= [80]
force_skip_degraded = [2,5,8,13,21,22,51,54,58,60,67,68]

t = TRECOCRParser.new(ARGV[0].to_i, force_skip_degraded, force_skip_origin)
t.main
