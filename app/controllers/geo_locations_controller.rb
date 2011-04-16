class GeoLocationsController < ApplicationController

  before_filter :login_required, :except => [:index, :show]
  helper :map

  def index
    @locations = GeoLocation.with_geo_place.with_visible_groups(current_user, current_site)
    respond_to do |format|
      format.kml { render :template => '/map/index_by_latlong.kml.builder',  :layout => false }
    end
  end

  def show
    return false unless @location = GeoLocation.find(params[:id])
    @groups = @location.groups.visible_by(current_user).slice!(0,12).paginate(:per_page => 4, :page => params[:page])
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace 'popup_entities_list', :partial => 'map/kml_entities_list'
        end
      }
    end
  end

end
