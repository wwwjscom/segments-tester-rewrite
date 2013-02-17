require_relative "application"


class Queries < Application
    
  def initialize
    @queries = []
  end
  
  # Returns the queries array.
  # Mainly just for syntactic sugar since @queries.queries looks ugly.
  def all
    @queries
  end
  
  def <<(query)
    @queries << query
  end

end


class Query < Application

  attr_accessor :solution_id, :solution, :misspelled
  
  def initialize(solution_id, solution, misspelled)
    @solution_id = solution_id
    @solution    = solution
    @misspelled  = misspelled
  end
  
end