require "code/segments"

describe Segments do
	
	before(:all) do
		@seg = Segments.new
	end
	
	it 'should find' do
		results = Segments.find('query0')
		results.class.should == Hash
		results['query0'].should == 6
		results['query1'].should == 3
		results['query2'].should == 3
	end
	
end