require_relative "../code/segments"

describe Segments do
	
	before(:all) do
		@seg = Segments.new
	end
	
	it 'should find' do
		results = @seg.find('solution0')
		results.class.should == Candidates
		results.find_by_solution('solution0').class.should == Candidate
		results.find_by_solution('solution0').votes.should == 15.0
		results.find_by_solution('solution1').votes.should == 6.0
		results.find_by_solution('solution2').votes.should == 6.0
	end
	
	it 'should method 1' do
		segments = @seg.method_1('Slovakia')
		segments[0].should == '%lovaki%'
		segments[1].should == '%ovak%'
		segments[2].should == '%va%'
		segments.size.should == 3
	end
	
	it 'should method 3' do
		segments = @seg.method_3('Slovakia')
		segments[0].should == 'Slov%kia'
		segments[1].should == 'Slov%ia'
		segments[2].should == 'Slo%ia'
		segments[3].should == 'Slo%a'
		segments[4].should == 'Sl%a'
		segments[5].should == 'Sl%'
		segments[6].should == 'S%'
		segments.size.should == 7
	end
	
	it 'should method 4' do
		segments = @seg.method_4('Slovakia')
		segments[0].should == '%akia'
	end
	
	it 'should method 5' do
		segments = @seg.method_5('Slovakia')
		segments[0].should == 'Slov%'
	end
	
	it 'should method 6' do
		segments = @seg.method_6('Slovakia')
		segments[0].should == 'S%a'
	end
	
	it 'should method 7' do
		segments = @seg.method_7('Slovakia')
		segments[0].should == 'Sl%ia'
	end

end
