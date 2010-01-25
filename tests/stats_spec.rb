require "spec"
require "code/stats"

describe Stats do

	before(:all) do
		@s = Stats.new("test engine")
		
		solution	= 'solution2'
		solution_id = 0
		
		c1 = Candidate.new('solutio0', 'solution0', 0, 10)
		c2 = Candidate.new('solutio1', 'solution1', 1, 10)
		c3 = Candidate.new('solutio2', 'solution2', 2, 20)
		
		cans1 = Candidates.new
		cans1.add(c1)
		cans1.add(c2)
		cans1.add(c3)
		e1 = Evaluator.new(cans1, solution, solution_id)
		
		cans2 = Candidates.new
		cans2.add(c1)
		cans2.add(c2)
		e2 = Evaluator.new(cans2, solution, solution_id)
		
		cans3 = Candidates.new
		cans3.add(c1)
		cans3.add(c2)
		e3 = Evaluator.new(cans3, solution, solution_id)
		
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