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
		results.size.should == 3
		results['solution0'].should == 1
		results['solution1'].should == 1
		results['solution2'].should == 1
	end
end