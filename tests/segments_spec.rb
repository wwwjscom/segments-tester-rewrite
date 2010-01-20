require "code/segments"

describe Segments do
	
	before(:all) do
		@seg = Segments.new
	end
	
	it 'should find' do
		results = Segments.find('solution0')
		results.class.should == Hash
		results['solution0'].should == 30
		results['solution1'].should == 10
		results['solution2'].should == 10
	end
	
end