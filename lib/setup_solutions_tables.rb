require_relative "../code/configs"
require_relative "../code/ngram"
require_relative "../code/sql"
require_relative "../code/application"
require_relative "../code/dm_soundex"

# Used to run migrations during setup
class Migrations < ActiveRecord::Migration
end

# Public: Various methods used for setting up the database
class SetupSolutionsTables < Application

    attr_accessor :ngram_objs, :dm_soundex_objs

    # Public: Setup the config; create the database if it doesnt exist;
    # read in the file with the queries to be used (path defined in
    # the config file).
    #
    # Returns nothing.
    def initialize
        @config = Configs.read_yml
        puts `mysql -u #{@config['db_user']} --password=#{@config['db_pass']} -e "CREATE DATABASE IF NOT EXISTS #{@config['db_db']}"`
        read_file
    end

    # Private: Does the reading and parsing of the queries file.
    #
    # Returns nothing.
    def read_file
        @lines_index = 0
        @lines = []
        file = (SEG_ENV =~ /test/i) ? 'db/solutions_rspec.csv' : @config['input_file']
        file = File.open(file)
        while line = file.gets do
            next if line.downcase.include?("j")
            @lines << line
        end
    end

    # Private: ...
    def has_next?
        @lines_index < @lines.size
    end

    # Private: ...
    def next
        @lines_index += 1
        @lines[@lines_index-1].chomp
    end

    # Public Drops the table of a specific engine
    #
    # Returns nothing
    def drop_table(engine)
        begin
            Migrations.drop_table("#{@config['queries_table']}_#{engine}") 
        rescue 
            Log.to_term("#{engine} table doesn't exist to be dropped...", "WARN")
        end
    end

    # Inserts a set of data into the correct table
    # We don't use auto-incrementing id's because it'll cause a problem
    # with ngrams...therefore the id column MAY NOT BE UNIQUE, but will
    # always map to a unique misspelled/solution pair.
    def insert(type, type_attr, solution, id)
        ActiveRecord::Base.connection_pool.with_connection do |conn|
            conn.execute "INSERT INTO #{@config['queries_table']}#{type} (`id`, `#{type.gsub('_', '')}`, `solution`) VALUES (#{id}, LCASE('#{type_attr}'), LCASE('#{solution}'))"
            ActiveRecord::Base.connection_pool.checkin(conn)
        end
    end

    # Parses the line and returns a hash of its contents
    def parse(line)
        hash = { :misspelled => line.split(',')[0].chomp, :solution => line.split(',')[1].chomp }
    end

    def setup_queries_table
        make_table('_misspelled')
        id = 1
        @lines.each do |line|
            line = parse(line)
            insert('_misspelled', line[:misspelled], line[:solution], id)
            id += 1
        end
    end

    # Private: Create a db table
    #
    # type - the type of engine we are using. Should be one of the following:
    #   "_dm_soundex", "_misspelled", "_3grams", "_4grams"
    #
    # Returns nothing
    def make_table(type)
        ActiveRecord::Base.connection.execute "CREATE TABLE IF NOT EXISTS #{@config['queries_table']}#{type} (`id` INT NOT NULL, `#{type.gsub('_', '')}` VARCHAR(255) NOT NULL, `solution` VARCHAR(255) NOT NULL)"
    end

    # Private: Checks to see if we have too many threads.
    # If so, hold off on creating more until some finnish.
    #
    # threads - an array of Tread objects
    #
    # Returns only when ready to proceed.
    def prevent_thread_saturation(threads)
        hold = false
        while threads.delete_if{ |t| !t.alive? }.size >= 50 or hold
            sleep 0.1
            puts "(#{threads.size}) - sleeping"
            hold = true
            hold = false if threads.size <= 30
        end
    end

    # Public: Main method for generating and inserting the dm soundex encodings
    #
    # Returns nothing
    def generate_dm_soundex_encodings
        type = "_dm_soundex"
        make_table(type)
        threads = []
        id = 1
        @lines.each do |line|
            query = parse(line)[:solution]
            next if query.downcase.include?("j")
            threads << new_dm_soundex_thread(query, id)

            # Don't wanna saturate the machien in threads
            print "."*threads.size
            puts "(#{threads.size})"
            prevent_thread_saturation(threads)

            id += 1
        end
    end

    # Private: Kicks off a new dm soundex thread that will
    # encode and insert the encoding
    #
    # query - The query to be encoded
    # id - the int id of the solution. Used on insertion.
    #
    # Returns a Thread object
    def new_dm_soundex_thread(query, id)
            Thread.new(query, id) { |myQuery, myId|
                obj = DMSoundex.new(myQuery)
                encoding = obj.encoding
                insert('_dm_soundex', encoding, obj.query, myId)
            }
    end

    # Public: Main method for generating and inersting the ngram encodings
    #
    # Returns nothing
    def generate_ngrams(n)
        threads = []
        type = (n == 3) ? "_3grams" : "_4grams"
        make_table(type)
        id = 1
        @lines.each do |line|
            query = parse(line)[:solution]
            threads << new_ngram_thread(query, id, type, n)

            # Don't wanna saturate the machien in threads
            prevent_thread_saturation(threads)

            id += 1
        end
    end

    # Private: Kicks off a new ngrams thread that will
    # encode and insert the encoding
    #
    # query - The query to be encoded
    # id - the int id of the solution. Used on insertion.
    # type - the type of ngram:
    #   "_3grams", "_4grams"
    #
    # Returns a Thread object
    def new_ngram_thread(query, id, type, n)
        Thread.new(query, id, type, n) { |myQuery, myId, myType, n|
            obj = Ngram.new(n, myQuery)
            obj.grams.each do |gram|
                insert(myType, gram, obj.query, myId)
            end
        }
    end
end
