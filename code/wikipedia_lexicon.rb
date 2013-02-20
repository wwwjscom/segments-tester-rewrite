#require "mysql"
require_relative "configs"
require_relative "application"
require_relative "candidates"

class WikipediaLexicon < ActiveRecord::Base
	self.table_name = "wikipedia_words"
	
	
end