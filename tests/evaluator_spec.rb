require "spec"
require_relative "../code/evaluator"
require_relative "../code/candidates"

describe Evaluator do
	
	before(:all) do
		c1 = Candidate.new('solutio0', 'solution0', 0, 20)
		c2 = Candidate.new('solutio1', 'solution1', 1, 10)
		c3 = Candidate.new('solutio2', 'solution2', 2, 10)
		
		cans1 = Candidates.new
		cans1.add(c1)
		cans1.add(c2)
		cans1.add(c3)
		
		solution        = 'solution0'
		solution_id     = 1
		
		@e = Evaluator.new(cans1, solution, solution_id)
		
		# Setup an example to utalize true rank (notice the tie amoung votes...)
		c1_alt = Candidate.new('solutio0', 'solution0', 0, 10)
		cans2 = Candidates.new
		cans2.add(c1_alt)
		cans2.add(c2)
		cans2.add(c3)
		@e2 = Evaluator.new(cans2, solution, solution_id)

		c2_alt = Candidate.new('solutio1', 'solution1', 0, 5)
		cans3 = Candidates.new
		cans3.add(c1_alt)
		cans3.add(c2_alt)
		cans3.add(c3)
		@e3 = Evaluator.new(cans3, "solution1", 1)
		
		c3_alt = Candidate.new('solutio2', 'solution2', 0, 8)
		cans4 = Candidates.new
		cans4.add(c1_alt)
		cans4.add(c2_alt)
		cans4.add(c3_alt)
		@e4 = Evaluator.new(cans4, "solution2", 2)
		
		# Setup an example where solution isn't found
		cans5 = Candidates.new
		cans5.add(c2_alt)
		cans5.add(c3_alt)
		@e_bad = Evaluator.new(cans5, solution, solution_id)
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
