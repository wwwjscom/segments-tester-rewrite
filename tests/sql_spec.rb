require_relative '../code/sql'
require_relative "../code/configs"
require_relative "../code/application"

describe SQL do
	
	before(:all) do
		@app = Application.new
		@config = Configs.read_yml
		@db = SQL.new(@config["db_user"], @config["db_pass"], @config["db_test_db"], true)
	end
	
	it 'should populate @queries' do
	  pending "Need to be updated -- doesn't call test table it appears"
		@db.populate(@config)
		@db.queries.class.should == Array
		@db.queries[0].class.should == Hash
	end

	it 'should work with has_next?' do
	  pending "Need to be updated -- doesn't call test table it appears"
		@db.populate(@config)
		@db.queries.size.should == 3
		@db.has_next?.should == true
		3.times do 
			@db.next
		end
		@db.has_next?.should == false
	end
	
	it 'should work with next' do
	  pending "Need to be updated -- doesn't call test table it appears"
	  
		@db.populate(@config)
		
		3.times do |i|
			hash = @db.next
			hash.class.should == Hash
			hash["misspelled"].should == "solutio#{i}"
			hash["solution"].should == "solution#{i}"
		end
	end
	
  it 'should initialize correctly' do
    @db.user.should     == 'root'
    @db.pass.should     == 'root'
    @db.database.should == 'segments_1234'
  end

  it 'should query correctly with 1 result' do
    result = @db.query "select * from #{@app.get_db}.#{@config['queries_table']}_misspelled ORDER BY misspelled LIMIT 1;"
    result.fetch_row[1].should == "solutio0"
  end

  it 'should query correctly with >1 result' do
    result = @db.query "select * from #{@app.get_db}.#{@config['queries_table']}_misspelled ORDER BY misspelled LIMIT 2;"
    result.fetch_row[1].should == "solutio0"
    result.fetch_row[1].should == "solutio1"
  end

  it 'should query correctly with an empty string' do
    results = @db.query ''
  end

end
