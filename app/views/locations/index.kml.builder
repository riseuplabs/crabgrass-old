xml.instruct! :xml
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
  xml.Document {
    @entities.each do |entity|
      next unless entity.try(:profile)? and !entity.profile.geo_place_id.nil?
      place = GeoPlace.find(entity.profile.geo_place_id)
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
