require 'yaml'
require_relative "sql"
require_relative "configs"
require_relative "tester"
require_relative "application"
require_relative "evaluator"
require_relative "stats"
require_relative "synthetic"
require_relative "wikipedia_lexicon"

class Main < Application

  attr_writer :search_type
	attr_reader :config

	def initialize
		Log.clear
	  Log.to_term("Initializing", "DEBUG")
		@config   = Configs.read_yml
		@s_3grams = Stats.new('3grams')
		@s_seg    = Stats.new('Segments')
    @max_tests = Application.get_config["max_tests"]
		Log.to_term("Done initializing", "DEBUG")
	end


  def run_for_a_query_term(query_term)
    
    # First, check for an exact match
    #return query_term if WikipediaLexicon.find_by_word(query_term) != nil
    Log.to_term "Searching..."
    find(nil, nil, query_term)
    Log.to_term "Done searching"
#    swap_results?
  end

	def run_for_a_bigram_query_term(query_bigram)
	  puts "Bigram: #{query_bigram}"
    @bigram_tester = Tester.new
		@bigram_tester.find(query_bigram, true)
		
		# Remove the 0.0 vote candidates
		@bigram_tester.seg_candidates.prune
    
		# Grab the max bigram votes
		max_bigram_votes = 0.0
		total_votes = @bigram_tester.seg_candidates.total_votes
		@bigram_tester.seg_candidates.candidates.each { |c| max_bigram_votes = c.votes if c.votes > max_bigram_votes }
		
		# Now remove the candidates who received fewer than half the votes of the highest scored candidates
		@bigram_tester.seg_candidates.candidates.delete_if { |c| c.votes < max_bigram_votes/2 }		
    
    # If ngrams only has a single candidate, we're very confident in our recomendation
#		if @bigram_tester.seg_candidates.size > 1 &&  max_bigram_votes < total_votes/2
		if @bigram_tester.seg_candidates.size > 1
		  puts "!!! \tA single bigram failed to get over half the votes..."
	  elsif @bigram_tester.seg_candidates.size == 1
	    # Couldn't this create a problem where just one result is returned, but we're
	    # not actually confident in it...but since the size is one this if statement
	    # thinks we are...hmmm....will this be a problem?  If so, how to fix...?
	    Log.to_term "Bigrams is very confident...dun dun dun!"
	    @bigrams_is_very_confident = true
	  end
		
		# Debug loop
		@bigram_tester.seg_candidates.candidates.each do |c|
		  puts "Bigram candidate: #{c.solution}\t#{c.votes}"
	  end
  end


  # This method gets all of the web queries.  For each query, it
  # breaks it down by word, and sends the word to the spell checking
  # algorithms for their candidate sets and probabilities.
  #
  # It then aggregates all the sets together to return a final recomendation (somehow...)
	def run
		i = 0
		@candidate_terms_sets = nil
		f1, recall, precision = 0.0, 0.0, 0.0
		
		WebQuery.where(:error_type => 2).each_with_index do |query, query_num|
    #WebQuery.find_each do |query|
    
      @skip = false
      
      puts "Running query: #{query.inspect}"
      
      query_terms           = query.user_query.split(/\W/)
      @candidate_terms_sets = []

      # Pass the query term to the correction algorithms for querying      
      query_terms.each_with_index do |query_term, term_index|
        
        if @bigrams_is_very_confident
          # The previous result was short circuited by bigrams results, so skip
          # this word too - since bigrams' last result already submmited a guess
          # for this query term.
          @bigrams_is_very_confident = false
          next
        end
        
        run_for_a_query_term(query_term)
        
        if term_index+1 < query_terms.size
          bigram = "%s %s" % [query_terms[term_index], query_terms[term_index+1]]
          run_for_a_bigram_query_term(bigram)
        end

        # Prune results
        @tester.seg_candidates.prune unless @tester.seg_candidates.size == 1
        
        # Store the recomendations for this query term
        @candidate_terms_sets[term_index] = Hash.new
        @candidate_terms_sets[term_index][:segments_candidates] = @tester.seg_candidates
      
        # If bigrams is very confident in results it found, lets go ahead and ignore the
        # unigram candidates.  Reasoning here is cause if you found two works that match
        # our query with high confidence, that's more likely to be what we want rather
        # than a single word match.
        #
        # So, lets go ahead and hack the shit out of the structure that the evaluation
        # process depends on so that we can just inject the candidates without having
        # to update/edit the rest of the code beyond this if statement.  Ugly yes...
        # but the deadline is closing in.
        if @bigrams_is_very_confident
          Log.to_term "Bigrams is very confident.  Going to short circuit the rest of the code in favor of its results"
          bigram_candidate = @bigram_tester.seg_candidates.candidates.first
          Log.to_term "Bigrams candidate: #{bigram_candidate.solution}"
          bigram_word_1, bigram_word_2 = bigram_candidate.solution.split(" ")
          bigram_word_1_candidate = Candidates.new.add(Candidate.new(bigram_candidate.misspelled, bigram_word_1, bigram_candidate.id))
          bigram_word_2_candidate = Candidates.new.add(Candidate.new(bigram_candidate.misspelled, bigram_word_2, bigram_candidate.id))
          @candidate_terms_sets[term_index][:segments_candidates]   = bigram_word_1_candidate # first word of the bigram as a candidate instance
          @candidate_terms_sets[term_index+1]                       = Hash.new # second word of the bigram as a candidate instance
          @candidate_terms_sets[term_index+1][:segments_candidates] = bigram_word_2_candidate # second word of the bigram as a candidate instance
          
          next # Go ahead and move on to the next query term since we believe we already found this one (and the next one)
        end

      end # query_terms.each_with_index

      
      # Now tim the candidate terms set to those that meet our probability threadhold
      @candidate_terms_sets.each_with_index do |query_term_candidates, term_index|
        seg_candidates = query_term_candidates[:segments_candidates]
        total_votes = seg_candidates.total_votes

        # Only take the top cancidate for each query term.  Their rank is determined by
        # the votes casted for them.
        seg_candidates.candidates = [seg_candidates.candidates.sort!{ |a,b| b.votes <=> a.votes }[0]]
        
        #   Also prune candidate who have insufficient confidence.
#        seg_candidates.candidates.delete_if { |c| c.votes/total_votes < 0.05}  
        

        # Skip is segments unigrams failed to find any candidates
        if seg_candidates.candidates.first == nil
          @skip = true
          break
        end
        
        
        # Now more pruning.  Find the index (if any) where there is a dramatic dropoff of
        # votes for a candidate with respect to the highest ranked candidate.      
        highest_votes = seg_candidates.candidates.first.votes
        break_index   = -1
        seg_candidates.candidates.each_with_index do |candidate, index|
          if candidate.votes < (highest_votes/2.0)
            break_index = index-1
            break
          end
        end
        seg_candidates.candidates = seg_candidates.candidates[0..break_index]
        
        
        # Recalculate the total votes so that our probabilities of the terms
        # that made is past the threadhold sum to 1.
        total_votes = seg_candidates.total_votes
        
        Log.to_term "Suggestions for term #{term_index}"
        # Now display the final results set
        seg_candidates.candidates.each do |c|
          Log.to_term "\t%s\t%s\t%s" % [c.solution, c.votes, c.votes/total_votes]
        end        
      end
      
      # Skip is segments unigrams failed to find any candidates
      next if @skip
            
      # Now constrcute all the permutations of possible result strings that may exist
      # given our candidates sets.
      Log.to_term "Permutation time"
      combined = []
      @candidate_terms_sets.each { |query_term_candidates| combined << query_term_candidates[:segments_candidates].candidates }
      combined_perms = combined.flatten.permutation(query_terms.size).to_a
      puts combined_perms.size
      
      final_list = []
      combined_perms.each_with_index do |query_candidates, array_index|
        skip_it = false
        query_terms.size.times do |term_index|
          unless @candidate_terms_sets[term_index][:segments_candidates].has_solution?(query_candidates[term_index].solution)
            skip_it = true
            break
          end
        end        

        final_list << query_candidates unless skip_it
      end
      Log.to_term "Permutations done"
      
      
      Log.to_term "****"*10
      Log.to_term final_list.size
      
      # Now sort the final list by probability, and return the top suggested queries
      final_list.sort{ |a,b| b.map(&:votes).inject(:+) <=> a.map(&:votes).inject(:+) }.each_with_index do |suggestion, index|

        puts suggestion.map(&:solution).join(" ")
#        puts suggestion.map(&:votes).inject(:+)/final_list.map(&:votes).inject(:+).to_f

        # Stop suggestion results if we've already suggestion too many, or the probability 
        # of our suggestions is becoming very low
        break if (index > 1) || ((suggestion.map(&:votes).inject(:+)/query_terms.size.to_f) < 4.0)
      end
      
      # Take only the highest rank suggestions to return to the user.
      final_list = [final_list[0]]
      
      correct_result_found = false
      # Calculate precision
      total_votes = 0.0
      final_list.each { |suggestion| suggestion.each { |candidate| total_votes += candidate.votes} }
      judgement_sets = [query.judge_1, query.judge_2, query.judge_3, query.judge_4] # Y(q)
      Log.to_term "Inspecting judgement sets: #{judgement_sets.inspect}"
      this_precision = 0.0
      final_list.each_with_index do |suggestion, index|
        suggestion_string = suggestion.map(&:solution).join(" ")
        Log.to_term "Check to see if #{suggestion_string} is in the judgements."
        i_p = judgement_sets.include?(suggestion_string) # I_q(y,q)
        Log.to_term "Survey says: #{i_p}"
        p = suggestion.map(&:votes).inject(:+)/total_votes
        this_precision += p if i_p
        
        correct_result_found = true if i_p
      end

      # Calculate recall
      this_recall = 0.0
      i_r = (correct_result_found) ? 1.0 : 0.0 # I_r(Y(q),a)      
      this_recall = i_r / final_list.size
      this_f1 = (2*(this_recall * this_precision)) / (this_precision + this_recall)
      
      
      Log.to_term "\t\tPrecision for this query: #{this_precision}"
      Log.to_term "\t\tRecall for this query: #{this_recall}"
      Log.to_term "\t\tF1 for this query: #{this_f1}"
      
      if correct_result_found
        precision += 1.0
        recall += 1.0
        f1 += 1.0
      end
      
      Log.to_term "\t\t-"*5
      Log.to_term "\t\tTotal queries run: #{query_num+1}"
      Log.to_term "\t\tRunning precision: #{(1.0/(query_num+1.0))*precision}"
      Log.to_term "\t\tRunning recall: #{(1.0/(query_num+1.0))*recall}"
      Log.to_term "\t\tRunning f1: #{(1.0/(query_num+1.0))*f1}"
      Log.to_term "\t\tRunning sum of f1: #{f1}"
      
      
      ########################################
      ############# READ THIS ################
      ########################################
      puts "Alive with query #{query.inspect}"
      next
      #return 0
      
      ########################################
      ############# READ THIS ################
      ########################################



      
      evaluate
  		results_from_this_query
      
      
      
      # Old below
      
      i+=1
      break if @max_tests != -1 && i >= @max_tests
      
      #p @queries.all.size	
      solution_id = query.id
      solution    = query.judge_1
      misspelled  = query.user_query

  		Log.to_term("Adding results", "DEBUG")
      add_results

  		Log.to_term("Logging findings", "DEBUG")
      log_findings

			Log.app ""
			Log.app "---- Start Post-(potential)-swap results: ----"
			results_from_this_query
			Log.app "---- End Post-(potential)-swap results: ----"
			Log.app ""

			Log.app "End search for #{solution} as #{misspelled}"
			Log.app "==============================================="
		end

		Log.to_term("Calculating stats", "DEBUG")
    calculate_stats

		# Display the results
		unless SEG_ENV =~ /test/i
			puts @s_3grams.to_s
			puts @s_seg.to_s

			Log.stats @s_3grams.to_s
			Log.stats @s_seg.to_s
		end

	end  
	
	def log_intermediary_results
	  Log.to_term("Calculating intermediary stats", "DEBUG")
    calculate_stats
    Log.intermediary_stats "-"*50
    Log.intermediary_stats "#{ENV["SYNTH_FUNC"]} x#{ENV["SYNTH_TIMES"]}"
    Log.intermediary_stats @s_3grams.to_s
		Log.intermediary_stats @s_seg.to_s
	end
	
	# Populates the queries instance variable based on the search type
	# so that we can later iterate over them.
	def setup_queries
	  @queries = case @search_type
    when :query_logs
      Log.to_term("Search Type: Query Logs", "DEBUG")
      sql = SQL.new
  	 	sql.populate(@config) # setup function
  	  sql.to_queries
    end # case
  end
	
	
	# Done adding results, calculate stats
	def calculate_stats
		@s_3grams.calculate
		@s_seg.calculate
	end
	
	
	def find(solution_id, solution, misspelled)
    @tester = Tester.new
		@tester.find(misspelled)
  end
  
  def evaluate
		@eval_3grams = Evaluator.new(@tester.grams_3_candidates, solution, solution_id, "3grams")
		@eval_seg    = Evaluator.new(@tester.seg_candidates, solution, solution_id, "seg")    
  end
  
  
  # Segments failed to meet the threshold, and is lower than 3grams,
	# so use the 3grams results for segments.
  def swap_results?
    if Evaluator.compare_confidence(@eval_seg, @eval_3grams) == "e2"
			@eval_seg = @eval_3grams
			Log.app 'Changing...', "DEBUG"
			Log.term "[Segments] Changing results"
		end
  end
  
  
  # Add to the stats instance variables
  def add_results
    @s_3grams.add(@eval_3grams)
		@s_seg.add(@eval_seg)
  end


	def results_from_this_query

		Log.app ""
		Log.app '3GRAMS'
		stats = @eval_3grams.found_and_rank
		Log.app "\tFound:#{stats[:found]}"
		Log.app "\tRank:#{stats[:rank]}" if stats[:found]

		Log.app 'SEGMENTS'
		stats = @eval_seg.found_and_rank
		Log.app "\tFound:#{stats[:found]}"
		Log.app "\tRank:#{stats[:rank]}" if stats[:found]
	end

end

