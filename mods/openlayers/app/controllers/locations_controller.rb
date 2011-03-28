class LocationsController
  helper 'map'

  def index 
    @map = OpenlayersMap.new('/groups/directory/search.kml')
  end

end
