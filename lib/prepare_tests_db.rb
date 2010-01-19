require "code/sql"
require "code/configs"
require "spec"

class PrepareTestsDb
	
	def initialize
		@config = Configs.read_yml
		@mysql = SQL.new(@config["db_user"], @config["db_pass"], @config["db_test_db"])
	end
	
	def setup
		@mysql.query("DROP TABLE IF EXISTS queries")
		@mysql.query("CREATE TABLE queries (`query` VARCHAR(255) NOT NULL, `solution` VARCHAR(255) NOT NULL)")
		@mysql.query("INSERT INTO queries VALUES('query', 'solution'), ('query2', 'solution2'), ('query3', 'solution3')")
		
		
#		result = @mysql.query("SELECT * FROM queries")
#		result.num_rows.should == 1
#		result.num_fields.should == 2
#		hash = result.fetch_hash
#		hash.class.should == Hash
#		hash["query"].should == 'query'
#		hash["solution"].should == 'solution'
	end
end