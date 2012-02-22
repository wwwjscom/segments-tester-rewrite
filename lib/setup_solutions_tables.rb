require "code/configs"
require "code/ngram"
require "code/sql"
require "code/application"
require "code/dm_soundex"

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

    def has_next?
        @lines_index < @lines.size
    end

    def next
        @lines_index += 1
        @lines[@lines_index-1].chomp
    end

    # DEPRECATED
    # Drops the given table from the db
    def drop_table(table_suffix = nil)
        sql = SQL.drop_table(table_suffix)
    end

    # Drops the table of a specific engine
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
        #sql = SQL.new
        #ActiveRecord::Base.connection.execute "CREATE TABLE IF NOT EXISTS #{@config['queries_table']}#{type} (`id` INT NOT NULL, `#{type.gsub('_', '')}` VARCHAR(255) NOT NULL, `solution` VARCHAR(255) NOT NULL)"
        #ActiveRecord::Base.connection.execute "INSERT INTO #{@config['queries_table']}#{type} (`id`, `#{type.gsub('_', '')}`, `solution`) VALUES (#{id}, LCASE('#{type_attr}'), LCASE('#{solution}'))"
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
        id = 1
        @lines.each do |line|
            line = parse(line)
            insert('_misspelled', line[:misspelled], line[:solution], id)
            id += 1
        end
    end


    # --- DM Soundex Methods ---

    # Generate the DM Soundex codes from the solutions prior to insertion
    def generate_dm_soundex_encodings
        type = "_dm_soundex"
        ActiveRecord::Base.connection.execute "CREATE TABLE IF NOT EXISTS #{@config['queries_table']}#{type} (`id` INT NOT NULL, `#{type.gsub('_', '')}` VARCHAR(255) NOT NULL, `solution` VARCHAR(255) NOT NULL)"
        threads = []
        id = 1
        @lines.each do |line|
            query = parse(line)[:solution]
            next if query.downcase.include?("j")
            threads << Thread.new(query, id) { |myQuery, myId|
                obj = DMSoundex.new(myQuery)
                encoding = obj.encoding
                Thread.current[:step] = 9
                insert('_dm_soundex', encoding, obj.query, myId)
                Thread.current[:step] = 10
            }
            # Don't wanna saturate the machien in threads
            print "."*threads.size
            puts "(#{threads.size})"
            hold = false
            while threads.delete_if{ |t| !t.alive? }.size >= 50 or hold
                sleep 0.1
                puts "(#{threads.size}) - sleeping"
                hold = true
                hold = false if threads.size <= 30
            end
            id += 1
        end
    end

    # Deprecated
    def insert_dm_soundex_encodings
        id = 1
        @dm_soundex_objs.each do |obj|
            encoding = obj.encoding
            insert('_dm_soundex', encoding, obj.query, id)
            id += 1
        end
    end


    # --- NGram Methods ---

    # Generates the ngrams from the solutions prior to inserting them
    def generate_ngrams(n)
        @ngram_objs = [] # Holds a bunch of ngram objects
        @lines.each do |line|
            query = parse(line)[:solution]
            @ngram_objs << Ngram.new(n, query)
        end
    end

    # Loops over the gram objects and calls insert on each
    def insert_ngrams(n)
        id = 1
        type = (n == 3) ? "_3grams" : "_4grams"
        @ngram_objs.each do |obj|
            obj.grams.each do |gram|
                insert(type, gram, obj.query, id)
            end
            id += 1
        end
    end
end
