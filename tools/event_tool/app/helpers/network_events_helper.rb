module NetworkEventsHelper
  def render_network_events(events)
    events.inject("") do |rendered, event|
      rendered ||= ""
      rendered << render(:partial => "network_events/#{event.action}_#{event.modified_type.constantize.table_name.singularize}", :locals => {:event => event})
    end
  end
end
