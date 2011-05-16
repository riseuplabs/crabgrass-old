class GeoLocationsController < ApplicationController

  helper :map, :locations, :autocomplete
  before_filter :fetch_location, :only => [:edit, :update, :new]
  before_filter :fetch_profile, :only => [:new, :create, :destroy]
  before_filter :login_required, :except => [:index, :show]
  before_filter :load_network

  permissions :geo_location, :profile

  COLORS = %w/pink yellow green blue orange dark-blue red light-blue purple dark-green/
  def index
    @locations = GeoPlace.with_visible_groups(current_user, current_site)
    if @network
      @locations = @locations.with_groups_in(@network)
    end
    if params[:pos]
      @color = COLORS[params[:pos].to_i - 1]
    else
      @color = COLORS.first
    end
    respond_to do |format|
      format.kml { render :template => '/map/index_by_latlong.kml.builder',  :layout => false }
    end
  end

  def show
    # this eventually should be expanded to also work for locations with only country or admin code set
    unless @place = GeoPlace.find(params[:id])
      render :nothing => true
      return
    end
    @groups = @place.group_profiles(current_user)
    if @network
      @groups = @groups.members_of(@network)
    else
      # i think this is covered by the group_profiles method now
      #@groups = @groups.visible_by(current_user)
    end
    @group_count = @groups.count
    @groups = @groups.slice!(0,12).paginate(:per_page => 4, :page => params[:page])
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace 'popup_entities_list', :partial => popup_partial_for(@groups)
        end
      }
    end
  end

  # the permissions for these are defined in app/permissions/geo_location_permissions.rb
  def destroy
    GeoLocation.delete(params[:id])
    redirect_to_group_or_user(@profile)
  end

  def edit
    return unless request.xhr?
    return if params[:location_only]
  end

  def new
    return unless request.xhr?
  end

  def create
    @profile.add_location!(params[:geo_location])
    redirect_to_group_or_user(@profile)
  end

  def update
    @location.update_params(params[:geo_location]) if params[:save]
    redirect_to_group_or_user(@location.profile)
  end

  private

  def load_network
    if params[:network_id]
      @network = Network.find_by_name params[:network_id]
    end
  end

  def fetch_location
    @location = GeoLocation.find_by_id(params[:id]) || GeoLocation.new(:profile_id => params[:profile_id])
    @city_name = !@location.geo_place_id.nil? ? @location.geo_place.name : ''
  end

  def fetch_profile
    @profile = Profile.find(params[:profile_id])
  end
  
  def redirect_to_group_or_user(profile)
    if profile.entity.is_a?(Group)
      redirect_to groups_profiles_url(:action => :edit, :params => {:id => profile.entity.name})
    else
      redirect_to '/profile/edit/'+profile.type
    end
  end

end
