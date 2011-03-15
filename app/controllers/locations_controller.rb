class LocationsController < ApplicationController

  helper 'autocomplete'
  permissions 'profile'

#  def all_admin_codes_options
  def country_dropdown_onchange 
    return unless request.xhr?
    # can select 'Country' which isn't really a country, and that should reset the form

    if params[:country_code] == "Country"
      geo_admin_codes = []
    elsif params[:show_admin_codes]
      geo_admin_codes = GeoCountry.find_by_id(params[:country_code]).geo_admin_codes
    end
    @profile = Profile.find(params[:profile_id]) if params[:profile_id]
    # do not try to update models unless there is a current profile (ie don't update models when in search)
    update_model_with_country(params[:country_code]) if @profile
    render :update do |page|

      page << "$$('option.newselected').collect(function(el){el.removeClassName('newselected')});" 
      page << "$('select_country_id').select('[value=\"#{params[:country_code]}\"]')[0].addClassName('newselected');" 
      page.replace 'autocomplete_js', :partial => '/locations/autocomplete_js'
      if params[:show_admin_codes]
        page.replace 'state_dropdown', :partial => '/locations/state_dropdown', :locals => {:display=>'inline', :name => params[:select_state_name], :geo_admin_codes => geo_admin_codes}
        page.show 'state_dropdown' 
      end
      page.show 'city_text'
      #page['city_id_field'].value = ''
      page.show 'submit_loc' if params[:show_submit] == 'true' 
    end
  end

  def update_city_id
    return unless request.xhr?
    render :update do |page|
      page["city_id_field"].value= params[:city_id]
    end
  end

  def update_widget_lat_and_long
    return unless request.xhr?
    place = GeoPlace.find(params[:city_id])
    render :update do |page|
      page["widget_map_center_latitude"].value = place.latitude
      page["widget_map_center_longitude"].value = place.longitude
    end
  end

  private

  def update_model_with_country(id)
    return unless may_edit_location_profile?(@profile.entity)
    @profile.update_location({:country_id => id}) 
  end

  def update_model_with_country(id)
    return unless may_edit_location_profile?(@profile.entity)
    @profile.update_location({:country_id => id}) 
  end

end
