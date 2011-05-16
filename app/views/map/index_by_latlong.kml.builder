xml.instruct! :xml
xml.kml(:xmlns => "http://earth.google.com/kml/2.2") {
  xml.Document {
    # todo take color from a param
    #color = 'pink'
    [50, 75, 100, 125, 150, 200].each do |scale|
      xml.Style(:id => "#{scale.to_s}Marker") { 
        xml.IconStyle {
          xml.scale(scale.to_f/100)
          xml.Icon{
            xml.href('/images/png/map/marker-pink.png')
          }
        }
      }
    end

    @locations.each do |location|
      location.group_count = location.group_count.to_i
      xml.Placemark {
        xml.styleUrl('#'+kml_style_for_place(location.group_count)+'Marker')
        xml.description(
          # this will need to be updated i think!
          'ajax:/geo_locations/show/'+location.id.to_s 
        )
        xml.Point {
          xml.coordinates(location.longlat)
        }
      }
    end
  }
}
