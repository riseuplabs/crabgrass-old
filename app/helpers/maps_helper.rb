module MapsHelper
  # rough first pass at mapping facilities for crabgrass
  # later on, may want to bring in some of the rails plugins
	# definitely want to use OpenLayers rather than Google Maps
  #  but for now, is sufficient
  # https://we.riseup.net/cdn/maps

  def map(lat=0,lng=0,edit=false,form_prefix='')

    content_id = "div"
    width = 500
    height = 400
    zoom = 4
  
    js = <<JS_END
<script type="text/javascript" src="http://www.google.com/jsapi?key=ABQIAAAAI9JNbb5_nx65OciX_mMjNxTX2XchcwgyHzp4Xo0DHRAzt2aLjhSBG2XLN24c0LpwgBl0NqPjQ7rF3w"></script>
<script>
google.load("maps",2);
var mapID = "map_#{content_id}";
if (!document.getElementById(mapID)){
	document.write("<div id='" + mapID + "' style='width:#{width}px; height:#{height}px'></div>");
}
JS_END

    if edit
      js += <<JS_END
if (!document.getElementById("lat")){
	document.write("<input type='hidden' id='#{form_prefix}[lat]' name='#{form_prefix}[lat]' value='#{lat}' />");
}
if (!document.getElementById("lng")){
	document.write("<input type='hidden' id='#{form_prefix}[lng]' name='#{form_prefix}[lng]' value='#{lng}' />");
}
JS_END
    end
    
    js += <<JS_END
google.setOnLoadCallback(function(){		
	map = new google.maps.Map2(document.getElementById(mapID));
	map.setCenter(new google.maps.LatLng(#{lat}, #{lng}), #{zoom});
	map.setMapType(G_PHYSICAL_MAP); 
	map.addControl(new google.maps.MapTypeControl());
	map.addControl(new google.maps.LargeMapControl());
	var markerCenter = new google.maps.LatLng(#{lat}, #{lng});
	var markerDescription = ("Latitude: #{lat}<br />Longitude: #{lng}");
JS_END

    if edit
      js += <<JS_END
  marker = new GMarker(markerCenter, {draggable: true});
  marker.enableDragging() ;
  google.maps.Event.addListener(marker, "dragend", function() {
    marker.openInfoWindowHtml("Just bouncing along...");
	  document.getElementById("#{form_prefix}[lat]").value=marker.getLatLng().lat();
    document.getElementById("#{form_prefix}[lng]").value=marker.getLatLng().lng();
	  marker.openInfoWindowHtml("Marker set to:<br />Latitude: " + marker.getLatLng().lat() + "<br />Longitude: " + marker.getLatLng().lng());
  });
JS_END
    else
      js += "var marker = new google.maps.Marker(markerCenter, {draggable: true});"
    end
    js += <<JS_END    
	google.maps.Event.addListener(marker, "dragstart", function() {
	  	map.closeInfoWindow();
	});
	map.addOverlay(marker);
	marker.openInfoWindowHtml(markerDescription);
}); 
  </script>
JS_END
  end

end
