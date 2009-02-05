class EventPage < Page


  # return a string for fulltext search...
  def body_terms
    [title, summary, data.description, data.city, data.state, data.country].join "\t"
  end

  alias_method(:event, :data)
  alias_method(:event=, :data=)
  
  def icon
    'date'
  end

  def delta=(val) 
    debugger
  end

end
