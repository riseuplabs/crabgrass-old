module MapHelper

  def display_map(kml_path, options = {})
    defaults = {
      :width => 500,
      :height => 355,
      :mapcenterlong => -8,
      :mapcenterlat => 8,
      :zoomlevel => 2 
    }
    defaults.merge!(options)
    defaults.merge!({:kml_path => kml_path})
    render :partial => 'locations/map', :locals => defaults 
  end

end
