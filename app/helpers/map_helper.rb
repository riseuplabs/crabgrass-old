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
      { :url => '/groups/show', :with => "'id=#{ent.name}&map_summary=1'",
        :loading => "$('entity-#{ent.id.to_s}').toggleClassName('spinner').toggleClassName('arrow');",
        :complete => "$('entity-#{ent.id.to_s}').toggleClassName('arrow').toggleClassName('spinner');"
      }
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

  def include_google_street_js_tag
    return unless current_site.evil.respond_to?(:[])
    return unless options = current_site.evil["google_streeets"]
    options.merge! 'sensor' => 'false'
    url = "http://maps.google.com/maps/api/js?"
    url += options.map{|k,v| "#{k}=#{v}"}.join(';')
    tag 'script', :src => url, :type => 'text/javascript'
  end
end
