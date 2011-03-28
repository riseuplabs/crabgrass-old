class LocationsController
  helper 'map'

  def index 
    @map = OpenLayers.new('/groups/directory/search.kml')
  end

end
