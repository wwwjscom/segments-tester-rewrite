require "code/dm_soundex"

describe DMSoundex do
	
	it 'should initialize ok' do
		# ...
	end
	
	it 'should encode correctly' do
		DMSoundex.new('Slovakia').encoding.should == '487500'
	end
	
	it 'should find by encoding' do
		dm = DMSoundex.new('query0')
		results = dm.find
		results.size.should == 3
		results[0]["dmsoundex"].should == '590000'
		results[0]["solution"].should == 'query0'
	end
end