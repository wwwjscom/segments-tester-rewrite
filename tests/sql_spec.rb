require 'code/sql'

describe SQL do
	
	before(:all) do
		@db = SQL.new('root', 'root', 'segments_tester', true)
	end
	
  it 'should initialize correctly' do
    @db.user.should     == 'root'
    @db.pass.should     == 'root'
    @db.database.should == 'segments_tester'
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

	it 'should populate @queries' do
		@db.populate(Config.read_yml)
		@db.queries.class.should == Array
		@db.queries[0].class.should == Hash
	end

end
