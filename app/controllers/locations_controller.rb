class LocationsController < ApplicationController

  def all_admin_codes_options
    html = '<option value="" selected>'+I18n.t(:location_state).capitalize+'</option>'
    GeoCountry.find_by_id(params[:country_code]).geo_admin_codes.each do |ac|
      html << "<option value='#{ac.id}'>#{ac.name}</option>"
    end
    render :update do |page|
      page.insert_html :top, 'select_state_id', html 
      page.show 'state_dropdown' 
      page.show 'city_text'
      page.show 'submit_loc' if params[:show_submit] == 'true' 
    end
  end

  def city_lookup
    city = params[:city]
    country_id = params[:country_id]
    admin_code_id = params[:admin_code_id]
    if params[:city_id_field] =~ /\S+/
      name = params[:city_id_field]+'[city_id]'
    else
      name = 'city_id'
    end
    html = ''
    if city.empty?
      # this should reset the state dropdown
      return
    end
    return if country_id.empty? 
    @places = GeoPlace.with_names_matching(city, country_id, params)
    if @places.empty?
      render :update do |page|
        page.replace_html 'city_results_box', "No cities matching '#{city}' found."
        page.show 'city_results_box'
      end
    elsif @places.size == 1
      return_single_city(@places[0])
    else
      render :update do |page|
        page.replace_html 'city_results_box', :partial => '/locations/link_to_city_id'
        page.show 'city_results_box'
      end
    end
  end

  def select_city_id
    city_id = params[:city_id]
    return_single_city(GeoPlace.find(city_id))
  end

  private

  def return_single_city(geoplace)
    html_for_text_box = geoplace.name.capitalize+', '+geoplace.geo_admin_code.name.capitalize
    html = "<input type='hidden' value='#{geoplace.id}' name='profile[city_id]' id='city_with_id_#{geoplace.id}' />"
    render :update do |page|
      page['city_text_field'].value = html_for_text_box
      page.replace_html 'city_results', html
      page.hide 'city_results_box'
    end
  end

end
