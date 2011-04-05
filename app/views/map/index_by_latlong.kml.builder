xml.instruct! :xml
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
  xml.Document {
    xml.Style(:id => "MarkerIcon") { 
      xml.IconStyle {
        xml.scale('.5')
        xml.Icon{
          xml.href('/images/png/map/map-marker.png')
        }
      }
    }      
    locations_with_visible_groups(@locations).each do |key, place|
      next unless place[:collection].count > 0
      xml.Placemark {
        xml.styleUrl('#MarkerIcon')
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
