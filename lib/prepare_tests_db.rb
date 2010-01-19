# Pretty sure this file is deprecated
require "code/sql"
require "code/configs"
require "spec"

class PrepareTestsDb
	
	def initialize
		@config = Configs.read_yml
		@mysql = SQL.new
	end
	
	def setup
		SQL.drop_table # drops queries table
		SQL.drop_table('_3grams')
		SQL.drop_table('_4grams')
		SQL.drop_table('_dm_soundex')
		@mysql.query("CREATE TABLE queries (`mispelled` VARCHAR(255) NOT NULL, `solution` VARCHAR(255) NOT NULL)")
		@mysql.query("INSERT INTO queries VALUES('query0', 'solution0'), ('query1', 'solution1'), ('query2', 'solution2')")
		
		
#		result = @mysql.query("SELECT * FROM queries")
#		result.num_rows.should == 1
#		result.num_fields.should == 2
#		hash = result.fetch_hash
#		hash.class.should == Hash
#		hash["query"].should == 'query'
#		hash["solution"].should == 'solution'
	end
end