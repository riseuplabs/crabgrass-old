module MapHelper

  def description_for_kml_location(location)
    if location.group_count > 1
      render :partial => '/map/kml_entities_list.html.haml',
        :locals => {:location => location}
    else
      @group = location.groups.visible_by(current_user).first
      render :partial => '/groups/profiles/map_summary.html.haml', :locals => {:no_back_link => 1}
    end
  end

  def link_to_kml_entity(ent)
    avatar_url = avatar_url_for(ent, 'small')
    style = "background-image:url(#{avatar_url});"
    link_to_remote ent.display_name,
      { :url => '/groups/show', :with => "'id=#{ent.name}&map_summary=1'"},
      { :class => 'big_icon', :style => style }
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

  def kml_style_for_place(count)
    return count.to_s if count <= 10
    case count.to_i
    when 11 .. 24
      '10'
    when 25 .. 49
      '25'
    when 50 .. 99
      '50'
    end
    '100'
  end

end
