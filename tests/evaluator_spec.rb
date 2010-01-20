require "spec"
require "code/evaluator"

describe Evaluator do
	
	before(:all) do
		candidates_hash = {"solution0"=>20, "solution1"=>10, "solution2"=>10}
		solution = 'solution0'
		@e = Evaluator.new(candidates_hash, solution)
		
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
		@e.rank.should == 0
	end
		
end