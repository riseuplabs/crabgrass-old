xml.instruct! :xml
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
  xml.Document {
    @places.each do |place|
      xml.Placemark {
        xml.name(place[:name])
        xml.description(h(place[:description]))
        xml.Point {
          xml.coordinates("#{place[:long]},#{place[:lat]}")
        }
      }
    end
  }
}
