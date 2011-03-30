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
    sort_entities_by_place(@entities).each do |key, place|
      xml.Placemark {
        xml.styleUrl('#MarkerIcon')
        xml.name(h(place[:name])+" (#{place[:total_count]})")
        xml.description(
          description_for_kml_place(place)
        )
        xml.Point {
          xml.coordinates(place[:longlat])
        }
      }
    end
  }
}
