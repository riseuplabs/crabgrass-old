xml.instruct! :xml
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
  xml.Document {
    [40, 45, 50, 75, 100].each do |scale|
      xml.Style(:id => "#{scale.to_s}Marker") { 
        xml.IconStyle {
          xml.scale(scale.to_f/100)
          xml.Icon{
            xml.href('/images/png/map/map-marker.png')
          }
        }
      }
    end

    @locations.each do |location|
      location.group_count = location.group_count.to_i
      xml.Placemark {
        xml.styleUrl('#'+kml_style_for_place(location.group_count)+'Marker')
        xml.description(
          description_for_kml_location(location)
        )
        xml.Point {
          xml.coordinates(location.geo_place.longlat)
        }
      }
    end
  }
}
