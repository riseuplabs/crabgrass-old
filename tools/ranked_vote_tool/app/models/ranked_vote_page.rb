class RankedVotePage < Page
    
  def initialize(*args)
    super(*args)
    self.data = Poll.new
  end
  
  # Return string of all poll possibilities, for the full text search index
  def index_data
    return "" unless data and data.possibles
    data.possibles.collect { |pos| "#{pos.name}\t#{pos.description}" }.join "\n"
  end

end

