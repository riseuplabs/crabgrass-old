class LocationsController

  permissions 'groups/base'

  def index
    @places = []
    GeoLocation.find(:all, :conditions => ['geo_place_id IS NOT NULL']).each do |gl|
      next unless profile = Profile.find_by_geo_location_id(gl.id)
 #     next unless profile.entity and profile.entity.is_a?(Group) and may_show_group?(profile.entity)
      place = {}
      place[:name] = profile.entity.try(:display_name) || profile.entity.name
      place[:description] = 'this is the location of entity '+place[:name]+' and can have a link <a href="foo">foo</a>'
      place[:lat] = GeoPlace.find(gl.geo_place_id).latitude
      place[:long] = GeoPlace.find(gl.geo_place_id).longitude
      @places << place
    end
    render :layout => false
  end

end
