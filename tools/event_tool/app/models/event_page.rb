class EventPage < Page
  define_index do
    indexes title
    indexes [summary, data.description, data.city, data.state], :as => 'content'
    has :public
    set_property :delta => true
  end

  alias_method(:event, :data)
  alias_method(:event=, :data=)
  
  def icon
    'date'
  end

end
