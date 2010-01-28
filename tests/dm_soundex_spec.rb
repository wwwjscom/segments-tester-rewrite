require "code/dm_soundex"

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
		results.size.should == 1
		results.find_by_solution('solution0').votes.should == 2.0
		results.find_by_solution('solution1').should == false
		results.find_by_solution('solution2').should == false
	end
end