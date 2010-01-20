require "spec"
require "code/evaluator"

describe Evaluator do
	
	before(:all) do
		candidates_hash = {"solution0"=>20, "solution1"=>10, "solution2"=>10}
		solution = 'solution0'
		@e = Evaluator.new(candidates_hash, solution)
		
		# Setup an example to utalize true rank (notice the tie amoung votes...)
		candidates_hash = {"solution2"=>10, "solution0"=>10, "solution1"=>10}
		@e2 = Evaluator.new(candidates_hash, solution)

		candidates_hash = {"solution2"=>10, "solution0"=>5, "solution1"=>10}
		@e3 = Evaluator.new(candidates_hash, "solution0")
		
		candidates_hash = {"solution2"=>10, "solution0"=>5, "solution1"=>8}
		@e4 = Evaluator.new(candidates_hash, "solution1")
		
		# Setup an example where solution isn't found
		candidates_hash = {"solution1"=>10, "solution2"=>10}		
		@e_bad = Evaluator.new(candidates_hash, solution)
	end
	
	it 'should mark found solutions' do
		@e.found?.should == true
	end
	
	it 'should not be found when needed' do
		@e_bad.found?.should == false
	end
	
	it 'should rank' do
		@e.rank.should == 1
		@e2.rank.should == 1
		@e3.rank.should == 3
		@e4.rank.should == 2
	end

	it 'should compute confidence' do
		@e.confidence.should == 0.5
		@e2.confidence.should == 0.33
		@e3.confidence.should == 0.2
		@e4.confidence.should == 0.35
	end
	
	it 'should compare confidence' do
		Evaluator.compare_confidence(@e, @e2).should == "e1"
		Evaluator.compare_confidence(@e2, @e3).should == "e1"
		Evaluator.compare_confidence(@e3, @e4).should == "e2"
	end
end