require_relative "../code/dm_soundex"

describe DMSoundex do
	
	it 'should initialize ok' do
		# ...
	end
	
	it 'should encode correctly' do
		DMSoundex.new('Slovakia').encoding.should == '487500'
	end
	
	it 'should find by encoding' do
		dm = DMSoundex.new('solution0')
		results = dm.find
		p results
		results.size.should == 3
		results.find_by_solution('solution0').votes.should == 1.0
		results.find_by_solution('solution1').votes.should == 1.0
		results.find_by_solution('solution2').votes.should == 1.0
	end
end