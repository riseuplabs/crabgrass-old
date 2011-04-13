class GeoLocationsController < ApplicationController

  helper :map
  permissions 'groups/base'
  before_filter :login_required, :except => [:index]
  before_filter :fetch_data

  def index
    respond_to do |format|
      format.kml { render :template => '/map/index_by_latlong.kml.builder',  :layout => false }
    end
  end

  def fetch_data
    @locations = GeoLocation.with_geo_place.with_visible_groups(current_user, current_site)
    if params[:network_id]
      @network = Network.find_by_name params[:network_id]
      @locations = @locations.with_groups_in(@network)
    end
  end
end
