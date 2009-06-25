class RankedVotePage < Page
  validates_presence_of :data, :on => :create, :message => "can't be blank"

  # Return string of all poll possibilities, for the full text search index
  def body_terms
    return "" unless data and data.possibles
    data.possibles.collect { |pos| "#{pos.name}\t#{pos.description}" }.join "\n"
  end

end

