require "spec"
require "code/ngram"

describe Ngram do
	
	before(:all) do
		@grams_3 = Ngram.new(3, 'test query')
		@grams_4 = Ngram.new(4, 'test query')
		@search_3grams = Ngram.new(3, 'solution0')
	end
	
	it 'should initialize' do
		# ...
	end

	it 'should return the correct 3grams' do
		@grams_3.grams.class.should == Array
		@grams_3.grams[0].should == 'tes'
		@grams_3.grams[1].should == 'est'
		@grams_3.grams[2].should == 'st '
		@grams_3.grams[3].should == 't q'
		@grams_3.grams[4].should == ' qu'		
		@grams_3.grams[5].should == 'que'
		@grams_3.grams[6].should == 'uer'
		@grams_3.grams[7].should == 'ery'
		@grams_3.grams[8].should == 'ry'
		@grams_3.grams[9].should == nil
	end
	
	it 'should return correct 4grams' do
		@grams_4.grams.class.should == Array
		@grams_4.grams[0].should == 'test'
		@grams_4.grams[1].should == 'est '
		@grams_4.grams[2].should == 'st q'
		@grams_4.grams[3].should == 't qu'
		@grams_4.grams[4].should == ' que'
		@grams_4.grams[5].should == 'quer'
		@grams_4.grams[6].should == 'uery'
		@grams_4.grams[7].should == 'ery'
		@grams_4.grams[8].should == 'ry'
		@grams_4.grams[9].should == nil
	end
	
	it 'should find with >1 matching 3gram' do
		matches = @search_3grams.find
		matches.class.should == Candidates
		matches.find_by_solution('solution0').votes.should == 7.0
		matches.find_by_solution('solution1').votes.should == 5.0
		matches.find_by_solution('solution2').votes.should == 5.0
	end 
	
end