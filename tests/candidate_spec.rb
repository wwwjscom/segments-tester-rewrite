require_relative "../code/candidates"

describe Candidates do
	
	it 'should create a candidate' do
		c = Candidate.new('bad', 'good', 0)
		c.class.should == Candidate
		c.id.should == 0
		c.solution.should == 'good'
		c.misspelled.should == 'bad'
	end
	
	it 'should know if it has a candidates already' do
		cans = Candidates.new
		cans.has_id?(0).should == false		
	end
	
	it 'should add candidates to the array' do
		c1 = Candidate.new('bad1', 'good1', 1)
		c2 = Candidate.new('bad2', 'good2', 2)
		c3 = Candidate.new('bad3', 'good2', 3)
		
		cans = Candidates.new
		cans.add(c1)
		cans.add(c2)
		cans.add(c3)
		
		cans.has_id?(0).should == false		
		cans.has_id?(1).should == true
		cans.has_id?(2).should == true
		cans.has_id?(3).should == true
	end
	
	it 'should vote for candidates' do
		c1 = Candidate.new('bad1', 'good1', 1)
		c2 = Candidate.new('bad2', 'good2', 2)
		
		cans = Candidates.new
		cans.add(c1)
		cans.add(c2)
		
		can = cans.vote_for(1, 2)
		can.votes.should == 2.0
	end
	
	it 'should sort by rank' do
		c1 = Candidate.new('bad1', 'good1', 1, 2)
		c2 = Candidate.new('bad2', 'good2', 2, 200)
		
		cans = Candidates.new
		cans.add(c1)
		cans.add(c2)
		
		sorted_array = cans.sort_by_rank
		sorted_array.class.should == Array
		sorted_array.size.should == 2
		
		sorted_array[0].votes.should == 200
		sorted_array[1].votes.should == 2
		
		# Try with inserting in a different order
		cans = Candidates.new
		cans.add(c2)
		cans.add(c1)
		
		sorted_array = cans.sort_by_rank
		sorted_array.class.should == Array
		sorted_array.size.should == 2
		
		sorted_array[0].votes.should == 200
		sorted_array[1].votes.should == 2
	end
	
	it 'should total votes' do
		c1 = Candidate.new('bad1', 'good1', 1, 2)
		c2 = Candidate.new('bad2', 'good2', 2, 200)
		
		cans = Candidates.new
		cans.add(c1)
		cans.add(c2)
		
		cans.total_votes.should == 202
	end
end