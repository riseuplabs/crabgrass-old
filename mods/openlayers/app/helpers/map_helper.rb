module MapHelper

  def display_map(kml_path, width=250, height=250)
    render :partial => 'locations/map', :locals => {:width => width, :height => height, :kml => kml_path}
  end

end
