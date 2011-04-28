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

end
