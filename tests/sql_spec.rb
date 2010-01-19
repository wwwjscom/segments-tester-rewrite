require 'code/sql'
require "code/configs"

describe SQL do
	
	before(:all) do
		@config = Configs.read_yml
		@db = SQL.new(@config["db_user"], @config["db_pass"], @config["db_test_db"], true)
	end
	
	it 'should populate @queries' do
		@db.populate(@config)
		@db.queries.class.should == Array
		@db.queries[0].class.should == Hash
	end

	it 'should work with has_next?' do
		@db.populate(@config)
		@db.queries.size.should == 3
		@db.has_next?.should == true
		3.times do 
			@db.next
		end
		@db.has_next?.should == false
	end
	
	it 'should work with next' do
		@db.populate(@config)
		
		3.times do |i|
			hash = @db.next
			hash.class.should == Hash
			hash["mispelled"].should == "query#{i}"
			hash["solution"].should == "solution#{i}"
		end
	end
	
  it 'should initialize correctly' do
    @db.user.should     == 'root'
    @db.pass.should     == 'root'
    @db.database.should == 'segments_1234'
  end

  it 'should query correctly with 1 result' do
    result = @db.query 'select * from segments_tester.query_logs_correct ORDER BY query LIMIT 1;'
    result.fetch_row[0].should == "banka"
  end

  it 'should query correctly with >1 result' do
    results = @db.query 'select * from segments_tester.query_logs_correct ORDER BY query LIMIT 2;'
    results.fetch_row[0].should == "banka"
    results.fetch_row[0].should == "batovce"
  end

  it 'should query correctly with an empty string' do
    results = @db.query ''
  end

end
