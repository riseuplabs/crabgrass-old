module MapHelper

  def description_for_kml_place(place, id)
    if place[:collection].count > 1
      render :partial => '/map/kml_entities_list.html.haml', :locals => {:place => place, :id => id}
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

  def locations_with_visible_groups(locations)
    places = {}
    locations.uniq.each do |loc|
      user = logged_in? ? current_user : nil
      total_count = Group.visible_by(user).in_location({:country_id => loc.geo_country_id, :city_id => loc.geo_place_id}).count
      next unless total_count > 0
      groups = Group.visible_by(user).in_location({:country_id => loc.geo_country_id, :city_id => loc.geo_place_id}).limit_to(3)
      gp = GeoPlace.find(loc.geo_place_id)
      id = loc.geo_place_id
      places[id] ||= {}
      places[id][:longlat] = "#{gp.longitude},#{gp.latitude}"
      places[id][:name] = gp.name + ', '+ loc.geo_country.code
      places[id][:country_id] = loc.geo_country_id
      places[id][:total_count] = total_count 
      places[id][:collection] = groups
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
    data[:name] = entity.display_name || entity.name
    data[:geo_place_id] = place.id
    data[:geo_place_name] = place.name + ', ' + place.geo_country.code
    data[:geo_country_id] = place.geo_country_id
    data[:lat] = place.latitude
    data[:long] = place.longitude
    return data
  end


end
