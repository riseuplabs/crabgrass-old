class GeoLocationsController < ApplicationController

  helper :map
  before_filter :login_required, :except => [:index, :show]
  before_filter :load_network
  def index
    @locations = GeoLocation.with_geo_place.with_visible_groups(current_user, current_site)
    if @network
      @locations = @locations.with_groups_in(@network)
    end
    respond_to do |format|
      format.kml { render :template => '/map/index_by_latlong.kml.builder',  :layout => false }
    end
  end

  def show
    return false unless @location = GeoLocation.find(params[:id])
    @groups = @location.groups
    if @network
      @groups = @groups.in_network(@network)
    end
    @groups = @groups.visible_by(current_user).slice!(0,12).paginate(:per_page => 4, :page => params[:page])
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace 'popup_entities_list', :partial => popup_partial_for(@groups)
        end
      }
    end
  end

  def load_network
    if params[:network_id]
      @network = Network.find_by_name params[:network_id]
    end    
  end
end
