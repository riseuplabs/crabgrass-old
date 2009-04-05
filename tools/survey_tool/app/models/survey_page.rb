class SurveyPage < Page
  # Return string of all poll possibilities, for the full text search index
  def body_terms
    return ""
    # return "" unless data and data.possibles
    # data.possibles.collect { |pos| "#{pos.name}\t#{pos.description}" }.join "\n"
  end
  
  def survey
    data
  end
end

