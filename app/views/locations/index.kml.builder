xml.instruct! :xml
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
  xml.Document {
    @entities.each do |entity|
      next unless data = geo_data_for_kml(entity)
      xml.Placemark {
        xml.name(h(data[:name]))
        xml.description(h(
          render :file => data[:description_template], :layout => false, :locals => {:entity => entity, :name => data[:name]}
        ))
        xml.Point {
          xml.coordinates("#{data[:long]},#{data[:lat]}")
        }
      }
    end
  }
}
