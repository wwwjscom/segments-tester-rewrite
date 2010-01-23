require "spec"

describe Tester do
	
	before(:all) do
		@t = Tester.new
	end
	
	it 'should call Tester.find(query) without error' do
		@t.find("solution0")
		
		# 3 grams checking
		grams_3_candidates = @t.grams_3_candidates
		grams_3_candidates.class.should == Hash
		grams_3_candidates["solution0"].should == 8
		grams_3_candidates["solution1"].should == 6
		grams_3_candidates["solution2"].should == 6
		
		# 4 grams checking
		grams_4_candidates = @t.grams_4_candidates
		grams_4_candidates.class.should == Hash
		grams_4_candidates["solution0"].should == 8
		grams_4_candidates["solution1"].should == 5
		grams_4_candidates["solution2"].should == 5

		# DM Soundex checking
		dm_candidates = @t.dm_candidates
		dm_candidates.class.should == Hash
		dm_candidates["solution0"].should == 1
		dm_candidates["solution1"].should == 1
		dm_candidates["solution2"].should == 1
		
		# Segments checking
#		seg_candidates = @t.seg_candidates
#		seg_candidates.class.should == Hash
#		seg_candidates["solution0"].should == 30
#		seg_candidates["solution1"].should == 10
#		seg_candidates["solution2"].should == 10
	end
	
end