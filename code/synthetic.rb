class Synthetic < Application
  def initialize(solution_id, solution, misspelled)
    @solution_id = solution_id
    @solution    = solution
    #  Misspelling is useless to us since we generate our own here.
  end
  
  # Takes a particular solution and synthetically alters it
  # in many different forms
  def to_synthetic(method, times)
    
    if @solution.respond_to?(method)
      @misspelled = @solution.send(method, times)
      self
    else
      raise "Unknown synthetic function: #{method}"
    end
  end
  
  def to_query
    Query.new(@solution_id, @solution, @misspelled)
  end
  
end


class String
	def drop_chr
	  s = String.new(self)
		begin
			len = s.length
			s[rand(len)] = ""
		rescue
		end
		return s
	end

	def drop_chrs times
	  s = String.new(self)
		for i in (1..times)
			s = s.drop_chr
		end
		return s
	end

	def add_chr
	  s = String.new(self)
		len = s.length
    letter = 'j'
    while letter == 'j' do
      letter = (rand(26) + 97).chr
    end
		s.insert(rand(len), letter)
		return s
	end

	def add_chrs times
	  s = String.new(self)
		for i in (1..times)
			s = s.add_chr
		end
		return s
	end

	def replace_chr
	  s = String.new(self)
		len = s.length

    letter = 'j'
    while letter == 'j' do
      letter = (rand(26) + 97).chr
    end

		s[rand(len)] = letter
		return s
	end

	def replace_chrs times
	  s = String.new(self)
		for i in (1..times)
			s = s.replace_chr
		end
		return s
	end

	def swap_chr
	  s = String.new(self)
		len = s.length
		
		i_a = rand(len)
		i_b = i_a

		while i_a == i_b do i_b = rand(len) end

		swap_a = s[i_a].chr
		swap_b = s[i_b].chr

		while swap_a == swap_b do
			i_b = rand(len)
			swap_b = s[i_b].chr
		end

		s[i_a] = swap_b
		s[i_b] = swap_a
		return s
	end

	def swap_chrs times
	  s = String.new(self)
		for i in (1..times)
			s = s.swap_chr
		end
		return s
	end

  # Times is a useless paramater.  Do not use it!
	def swap_adj_chr times
	  s = String.new(self)
		len = s.length
		
		i_a = rand(len - 1)
		while i_a >= len or i_a < 0 do i_a = rand(len - 1) end

		i_b = i_a + 1

		swap_a = s[i_a].chr
		swap_b = s[i_b].chr

		s[i_a] = swap_b
		s[i_b] = swap_a
		return s
	end
end
