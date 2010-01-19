require "code/dm_soundex"

describe DMSoundex do
	
	it 'should initialize ok' do
		# ...
	end
	
	it 'should encode correctly' do
		DMSoundex.new('Slovakia').encoding.should == '487500'
	end
end