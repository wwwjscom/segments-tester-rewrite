require "code/segments"

describe Segments do
	
	before(:all) do
		@seg = Segments.new
	end
	
	it 'should find' do
		pending('Broken by segments rewrite')
		results = Segments.find('solution0')
		results.class.should == Hash
		results['solution0'].should == 30
		results['solution1'].should == 10
		results['solution2'].should == 10
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

  it 'should merge candidates' do
    segments = @seg.method_1('solution0')
    candidates = @seg.find_candidates(segments)
    candidates["solution0"].should == 4
    merged = @seg.merge_candidates(candidates, candidates)
    merged["solution0"].should == 8
  end
end
