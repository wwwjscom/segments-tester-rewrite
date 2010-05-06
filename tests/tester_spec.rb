require "spec"

describe Tester do
	
	before(:all) do
		@t = Tester.new
	end
	
	it 'should call Tester.find(query) without error' do
		@t.find("solution0")
		
		# 3 grams checking
		grams_3_candidates = @t.grams_3_candidates
		grams_3_candidates.class.should == Candidates
		grams_3_candidates.find_by_solution("solution0").votes.should == 7.0
		grams_3_candidates.find_by_solution("solution1").votes.should == 5.0
		grams_3_candidates.find_by_solution("solution2").votes.should == 5.0
		
		# 4 grams checking
		grams_4_candidates = @t.grams_4_candidates
		grams_4_candidates.class.should == Candidates
		grams_4_candidates.find_by_solution("solution0").votes.should == 7.0
		grams_4_candidates.find_by_solution("solution1").votes.should == 4.0
		grams_4_candidates.find_by_solution("solution2").votes.should == 4.0

		# DM Soundex checking
		dm_candidates = @t.dm_candidates
		dm_candidates.class.should == Candidates
		dm_candidates.size.should == 3
		dm_candidates.find_by_solution("solution0").votes.should == 1.0		
		# Segments checking
#		seg_candidates = @t.seg_candidates
#		seg_candidates.class.should == Hash
#		seg_candidates["solution0"].should == 30
#		seg_candidates["solution1"].should == 10
#		seg_candidates["solution2"].should == 10
	end
	
end