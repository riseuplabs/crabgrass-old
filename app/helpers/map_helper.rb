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
    link_content = content_tag('span', avatar_for(ent, 'small') + ent.display_name)
    link_to_remote(link_content,
      :url => '/groups/show',
      :with => "'id=#{ent.name}&map_summary=1'")
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
    # return values are percents, so 1 count -> 25% marker
    case count.to_i
    when 1
      '40'
    when 2
      '45'
    when 3 .. 5
      '50'
    when 6 .. 10
      '75'
    when 11 .. 15
      '100'
    end
  end

end
