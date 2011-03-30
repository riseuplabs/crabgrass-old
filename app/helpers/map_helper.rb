module MapHelper
 
  def entities_for_kml_place(entities)
    html = '<ul>'
    entities.each do |ent|
      html += '<li>'+ent.name+'</li>'
    end
    html += '</ul>'
  end

end
