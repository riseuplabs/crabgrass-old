module MapHelper

  def popup_partial_for(groups)
    if groups.count > 1
      '/map/kml_entities_list.html.haml'
    else
      '/groups/profiles/map_summary.html.haml'
    end
  end

  def link_to_kml_entity(ent)
    link_to_remote ent.display_name,
      { :url => '/groups/show', 
        :with => "'id=#{ent.name}&map_summary=1&place_id=#{@place.id}'",
        :loading => "$('entity-#{ent.id.to_s}').toggleClassName('spinner').toggleClassName('arrow');",
        :complete => "$('entity-#{ent.id.to_s}').toggleClassName('arrow').toggleClassName('spinner');"
      }
  end

  def kml_style_for_place(count)
    case count.to_i
    when 1
      '50'
    when 2
      '75'
    when 3 .. 4
      '100'
    when 5 .. 8
      '125'
    when 7 .. 16
      '150'
    else
      '200'
    end
  end

  def include_google_street_js_tag
    return unless current_site.evil.respond_to?(:[])
    return unless options = current_site.evil["google_streets"]
    url = "http://maps.google.com/maps?file=api&v=2&"
    url += options.map{|k,v| "#{k}=#{v}"}.join('&')
    content_tag 'script', '', :src => url, :type => 'text/javascript'
  end
end
