xml.instruct! :xml
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
  xml.Document {
    @places.each do |key, place|
      xml.Placemark {
        xml.name(h(place[:name]))
        xml.description(
          entities_for_kml_place(place[:collection])
        )
        xml.Point {
          xml.coordinates(place[:longlat])
        }
      }
    end
  }
}
