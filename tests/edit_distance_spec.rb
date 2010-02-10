require "spec"
require "code/edit_distance"

describe EditDistance do
	
	it 'should work on days' do
		compare("Sunday", "Saturday", 3)
	end
	
	it 'should work on animals' do
		compare("kitten", "sitting", 3)
	end
	
	it 'shouldnt care about case' do
		compare("Sun", "sun", 0)
	end

	it 'should handle arrays' do
		misspelling = 'Sunday'
		data_set	= ['Snday', 'unday', 'xSunday'] # Should each have a distance of 1
		
		compare misspelling, data_set, [1, 1, 1]
	end
	
	it 'shouldnt care about case in arrays' do
		misspelling = 'sunday'
		data_set	= ['Snday', 'unday', 'xSunday'] # Should each have a distance of 1
		
		compare misspelling, data_set, [1, 1, 1]
	end
	
	def compare(q1, q2, distance)
		e = EditDistance.new(q1)
		e.match(q2).should == distance
	end

end