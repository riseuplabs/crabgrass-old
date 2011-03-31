module MapHelper

  def description_for_kml_place(place)
    if place[:collection].count > 1
      render :partial => '/map/kml_entities_list.html.haml', :locals => {:place => place}
    else
      @group = place[:collection][0]
      render :partial => '/groups/profiles/map_summary.html.haml', :locals => {:no_back_link => 1}
    end
  end
 
  def link_to_kml_entity(ent)
    link_content = content_tag('span', avatar_for(ent, 'small') + ent.display_name)
    link_to_remote(link_content, 
      :url => '/groups/show',
      :with => "'id=#{ent.name}&map_summary=1'")
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
