class GoogleMap
  attr_accessor :dom_id,
                :markers,
                :controls
  
  def initialize(options = {})
    self.markers = []
    self.dom_id = 'google_map'
    self.controls = [:zoom, :overview, :scale, :type]
    options.each_pair { |key, value| send("#{key}=", value) }
  end
  
  def to_html
    html = []
    
    html << "<script src='http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{GeoKit::Geocoders::google}' type='text/javascript'></script>"
    
    html << "<script type=\"text/javascript\">\n/* <![CDATA[ */\n"  
    html << to_js
    html << "/* ]]> */</script> "
    
    return html.join("\n")
  end

  def to_js
    js = []
    
    # Initialise the map variable so that it can externally accessed.
    js << "var #{dom_id};"
    markers.each { |marker| js << "var #{marker.dom_id};" }
    
    js << "function initialize_google_map_#{dom_id}() {"
    js << "  if(GBrowserIsCompatible()) {"
    js << "    #{dom_id} = new GMap2(document.getElementById('#{dom_id}'));"
    
    js << controls_js
    
    js << center_on_markers_js
    
    # Put all the markers on the map.
    for marker in markers
      js << marker.to_js
      js << ''
    end
    
    js << "  }"
    js << "}"
    
    # Load the map on window load preserving anything already on window.onload.
    js << "if (typeof window.onload != 'function') {"
    js << "  window.onload = initialize_google_map_#{dom_id};"
    js << "} else {"
    js << "  old_before_google_map_#{dom_id} = window.onload;"
    js << "  window.onload = function() {" 
    js << "    old_before_google_map_#{dom_id}();"
    js << "    initialize_google_map_#{dom_id}();" 
    js << "  }"
    js << "}"
        
    return js.join("\n")
  end
  
  def controls_js
    js = []
    
    controls.each do |control|
      case control
        when :large, :small, :overview
          c = "G#{control.to_s.capitalize}MapControl"
        when :scale
          c = "GScaleControl"
        when :type
          c = "GMapTypeControl"
        when :zoom
          c = "GSmallZoomControl"
      end
      js << "#{dom_id}.addControl(new #{c}());"
    end
    
    return js.join("\n")
  end
  
  def center_on_markers_js
    return "#{dom_id}.setCenter(new GLatLng(0, 0), 0);" if markers.size == 0
    
    for marker in markers
      min_lat = marker.lat if !min_lat or marker.lat < min_lat
      max_lat = marker.lat if !max_lat or marker.lat > max_lat
      min_lng = marker.lng if !min_lng or marker.lng < min_lng
      max_lng = marker.lng if !max_lng or marker.lng > max_lng
    end
    
    js = []
        
    js << "bounds = new GLatLngBounds(new GLatLng(#{min_lat}, #{min_lng}), new GLatLng(#{max_lat}, #{max_lng}));"
    js << "zoom = #{dom_id}.getBoundsZoomLevel(bounds);"
    js << "if (zoom>14) { zoom = 14 };"
    js << "center = new GLatLng(#{(min_lat + max_lat) / 2}, #{(min_lng + max_lng) / 2});"
    js << "#{dom_id}.setCenter(center, zoom);"

    return js.join("\n")
  end
  
  def div(width = '100%', height = '100%')
    "<div id='#{@dom_id}' style='width: #{width}; height: #{height}'></div>"
  end
end
