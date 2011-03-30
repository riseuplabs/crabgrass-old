module MapHelper

  def description_for_kml_place(place)
    content_tag('div', header_for_place(place) + entities_for_kml_place(place), :id => 'map_popup_description')
  end
 
  def entities_for_kml_place(place)
    html = ''
    html += '<ul>'
    place[:collection].each do |ent|
      html += '<li>' + link_to_kml_entity(ent) + '</li>'
    end
    html += '</ul>'
  end

  def link_to_kml_entity(ent)
    link_content = content_tag('span', avatar_for(ent, 'small') + ent.display_name)
  end

  def header_for_place(place)
    h3 = content_tag('h3', "#{place[:name]} (#{place[:collection].count})", :style => 'display: inline;')
    content_tag('span', h3, :class => 'small_icon world_16')
  end

  def sort_entities_by_place(entities)
    places = {}
    entities.each do |ent|
      data = {}
      next unless data = geo_data_for_kml(ent)
      next unless data[:lat] and data[:long]
      id = data[:geo_place_id]
      places[id] ||= {}
      places[id][:longlat] ||= "#{data[:long]},#{data[:lat]}"
      places[id][:name] ||= data[:geo_place_name]
      places[id][:country_id] ||= data[:geo_country_id]
      places[id][:collection] ||= []
      places[id][:collection] << ent
    end
    return places
  end

  def geo_data_for_kml(entity)
    # currently groups are only supported. when users are added the profile
    # would be entity.profile (groups location data is only stored in the public profile)
    if entity.is_a?(Group)
      profile = entity.profiles.public
    end
    return false unless profile and profile.city_id
    return false unless place = GeoPlace.find(profile.city_id)
    data = {}
    data[:geo_place_id] = place.id
    data[:geo_place_name] = place.name + ', ' + place.geo_country.code
    data[:geo_country_id] = place.geo_country_id
    data[:lat] = place.latitude
    data[:long] = place.longitude
    return data
  end


end
