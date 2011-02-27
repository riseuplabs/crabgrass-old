xml.instruct! :xml
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
  xml.Document {
    @entities.each do |entity|
      profile = entity.profiles.public
      next unless profile and profile.city_id
      place = GeoPlace.find(profile.city_id)
      xml.Placemark {
        xml.name(h(entity.try(:display_name) || entity.name))
        xml.description(h(kml_description(entity)))
        xml.Point {
          xml.coordinates("#{place[:long]},#{place[:lat]}")
        }
      }
    end
  }
}
