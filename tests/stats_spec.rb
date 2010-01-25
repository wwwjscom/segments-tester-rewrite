require "spec"
require "code/stats"

describe Stats do

	before(:all) do
		@s = Stats.new("test engine")
		
		solution	= 'solution2'
		solution_id = 0
		
		candidates 	= {"solution0"=>10, "solution1"=>10, "solution2"=>20}
		e1 = Evaluator.new(candidates, solution, solution_id)
		candidates 	= {"solution0"=>10, "solution1"=>10}
		e2 = Evaluator.new(candidates, solution, solution_id)
		candidates 	= {"solution0"=>10, "solution1"=>10}
		e3 = Evaluator.new(candidates, solution, solution_id)
		
		
		@s.add(e1)
		@s.add(e2)
		@s.add(e3)
	end
	
	it 'should average ranks' do
		@s.average_rank.should == 1.0
	end

	it 'should average percent found' do
		@s.found_percent.should == 33.33
	end
	
end