class EventPage < Page
  define_index do
    indexes title
    indexes [summary, data.description, data.city, data.state], :as => 'content'
    has :public
    set_property :delta => true
  end

  icon 'date.png'
  class_display_name 'event'
  class_description 'An event added to the personal/group/public calendar.'
    
  belongs_to :data, :class_name => '::Event', :foreign_key => 'data_id'
end
