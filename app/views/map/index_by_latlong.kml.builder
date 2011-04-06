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
    locations_with_visible_groups(@locations).each do |key, place|
      next unless place[:collection].count > 0
      xml.Placemark {
        xml.styleUrl('#'+kml_style_for_place(place[:total_count])+'Marker')
        xml.description(
          description_for_kml_place(place, key)
        )
        xml.Point {
          xml.coordinates(place[:longlat])
        }
      }
    end
  }
}
