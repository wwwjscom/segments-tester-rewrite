require_relative "../../code/application"
require_relative "../../code/ngram"
require_relative "../../code/queries"
require_relative "../../code/wikipedia_lexicon"

WikipediaLexicon.find_each do |wiki_data|  
  word  = wiki_data.word
  count = wiki_data.count

  ngram = Ngram.new(3, word)
  ngram.grams.each do |gram|
    Queries3grams.create(:gram => gram, :lexicon_word => word, :lexicon_count => count)
  end
end