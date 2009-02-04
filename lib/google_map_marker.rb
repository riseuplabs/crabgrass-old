class GoogleMapMarker
  include ActionView::Helpers::JavaScriptHelper
  
  attr_accessor :dom_id,
                :lat,
                :lng,
                :html,
                :map
                
  def initialize(options = {})
    options.each_pair { |key, value| send("#{key}=", value) }
    if lat.blank? or lng.blank? or !map or !map.kind_of?(GoogleMap)
      raise "Must set lat, lng, and map for GoogleMapMarker."
    end
    if dom_id.blank?
      # This needs self to set the attr_accessor, why?
      self.dom_id = "#{map.dom_id}_marker_#{map.markers.size + 1}"
    end
  end
  
  def to_js
    js = []
    
    js << "function #{dom_id}_infowindow_function() {"
    js << "  #{dom_id}.openInfoWindowHtml(\"#{escape_javascript(html)}\")"
    js << "}"
    
    js << "#{dom_id} = new GMarker(new GLatLng(#{lat}, #{lng}));"
    
    js << "GEvent.addListener(#{dom_id}, 'click', function() {#{dom_id}_infowindow_function()});"
    
    js << "#{map.dom_id}.addOverlay(#{dom_id});"
    
    return js.join("\n")
  end
end
