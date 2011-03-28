class LocationsController

  def index 
    @map = OpenlayersMap.new('/groups/directory/search.kml')
  end

end
