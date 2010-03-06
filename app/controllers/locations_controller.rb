class LocationsController < ApplicationController

  def all_admin_codes_options
    # can select 'Country' which isn't really a country, and that should reset the form
    if params[:country_code] == "Country"
      geo_admin_codes = []
    else
      geo_admin_codes = GeoCountry.find_by_id(params[:country_code]).geo_admin_codes
    end
    render :update do |page|
      page.replace 'state_dropdown', :partial => '/locations/state_dropdown', :locals => {:display=>'inline', :name => params[:select_state_name], :geo_admin_codes => geo_admin_codes}
      page.show 'state_dropdown' 
      page.show 'city_text'
      page['city_text_field'].value = '' 
      page['city_id_field'].value = ''
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
      render :update do |page|
        page["city_id_field"].value=''
      end
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
        page.replace_html 'city_results_box', :partial => '/locations/link_to_city_id', :locals => {:name => params[:city_id_name]}
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
    html_for_text_box = geoplace.name.capitalize
    html = "<input type='hidden' value='#{geoplace.id}' name='#{params[:city_id_name]}' id='city_id_field' />"
    render :update do |page|
      page["admin_code_#{geoplace.geo_admin_code.id}"].selected = true
      page['city_text_field'].value = html_for_text_box
      page.replace_html 'city_results', html
      page.hide 'city_results_box'
    end
  end

end
