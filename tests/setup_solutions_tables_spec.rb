require "spec"
require "/Users/wwwjscom/Code/Segments Tester/lib/setup_solutions_tables.rb"

describe SetupSolutionsTables do
	
	before(:all) do
		@sst = SetupSolutionsTables.new
	end
	
	it 'Should read in the file correctly' do
		@sst.read_file
		@sst.next.should == "solutio0,solution0"
	end
	
	it 'should use has_next? and next correctly' do
		@sst.read_file
		@sst.has_next?.should == true
		3.times do |i|
			@sst.next.should == "solutio#{i},solution#{i}"
		end
		@sst.has_next?.should == false
	end
	
	it 'should generate 3grams correctly' do
		@sst.generate_ngrams(3)
		objs = @sst.ngram_objs
		objs.class.should == Array
		objs[0].grams[0].should == 'sol'
	end

	it 'should generate 4grams correctly' do
		@sst.generate_ngrams(4)
		objs = @sst.ngram_objs
		objs.class.should == Array
		objs[0].grams[0].should == 'solu'
	end	
	
	it 'should generate dm soundex encodings' do
		@sst.generate_dm_soundex_encodings
		objs = @sst.dm_soundex_objs
		objs.class.should == Array
		objs[0].encoding.should == '483600'
	end

	
	it 'should parse lines' do
		line = "query,solution"
		hash = @sst.parse(line)
		hash.class.should == Hash
		hash[:misspelled].should == "query"
		hash[:solution].should == "solution"
	end
		
end