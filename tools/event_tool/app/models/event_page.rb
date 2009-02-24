class EventPage < Page


  # return a string for fulltext search...
  def body_terms
    return "" unless data and data.description
    return "\n#{data.description}\t#{data.location.street}\t#{data.location.city}\t#{data.location.country_name}\t#{data.location.directions}"
  end

  alias_method(:event, :data)
  alias_method(:event=, :data=)
  
  def icon
    'date'
  end

  def delta=(val) 
#    debugger
  end

end
