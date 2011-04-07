class GeoLocationsController < ApplicationController

  before_filter :login_required, :except => [:index]
  helper :map
  permissions 'groups/base'

  def index
    @locations = GeoLocation.with_geo_place.with_visible_groups(current_user, current_site)
    respond_to do |format|
      format.kml { render :template => '/map/index_by_latlong.kml.builder',  :layout => false }
    end
  end

end
