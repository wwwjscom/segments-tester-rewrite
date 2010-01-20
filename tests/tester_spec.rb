require "spec"

describe Tester do
	
	before(:all) do
		@t = Tester.new
	end
	
	it 'should call Tester.find(query) without error' do
		@t.find("query0")
		
		# 3 grams checking
		grams_3_candidates = @t.grams_3_candidates
		grams_3_candidates.class.should == Hash
		grams_3_candidates["query0"].should == 5
		grams_3_candidates["query1"].should == 3
		grams_3_candidates["query2"].should == 3
		
		# 4 grams checking
		grams_4_candidates = @t.grams_4_candidates
		grams_4_candidates.class.should == Hash
		grams_4_candidates["query0"].should == 5
		grams_4_candidates["query1"].should == 2
		grams_4_candidates["query2"].should == 2

		# DM Soundex checking
		dm_candidates = @t.dm_candidates
		dm_candidates.class.should == Hash
		dm_candidates["query0"].should == 1
		dm_candidates["query1"].should == 1
		dm_candidates["query2"].should == 1
		
		# Segments checking
		seg_candidates = @t.seg_candidates
		seg_candidates.class.should == Hash		
		seg_candidates["query0"].should == 6
		seg_candidates["query1"].should == 3
		seg_candidates["query2"].should == 3
	end
	
end