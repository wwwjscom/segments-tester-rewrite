require "spec"

describe Tester do
	
	it 'should call Tester.find(query) without error' do
		pending ('Need to make the ngrams class')
		results = Tester.find("query0")
		results.should == Hash
	end
	
end