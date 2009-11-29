class LocationsController < ApplicationController

  def replace_admin_codes_options
    html = ''
    GeoCountry.find_by_id(params[:country_code]).geo_admin_codes.each do |ac|
      html << "<option value='#{ac.id}'>#{ac.name}</option>"
    end
    render :update do |page|
      page.replace_html params[:replace_id], html 
    end
  end

  def show_search_admin_codes
    html = ''
    GeoAdminCode.with_public_profile(params[:country_id]).find(:all).each do |ac|
      html << "<option value='#{ac.id}'>#{ac.name}</option>"
    end
    render :update do |page|
      #page.replace_html 'select_state_id', html
      #page.show 'state_dropdown'
      page.show 'submit_loc'
    end
  end

  def city_lookup
    city = params[:city]
    return if city.empty?
    country_id = params[:country_id]
    admin_code_id = params[:admin_code_id]
    html = ''
    if country_id.empty? 
      html << 'Country is required.'
    else
      @places = GeoPlace.with_names_matching(city, country_id, params)
      if @places.empty?
        html << 'No matching cities found.'
      else
        html << '<ul>'
        @places.each do |place|
          next if place.nil?
          html << "<li><input type='checkbox' value='#{place.id}' name='profile[city_id]' />#{place.name}, #{place.geo_admin_code.name}</li>"
        end
        html << '</ul>'
      end
    end
    render :update do |page|
      page.replace_html 'city_results', html
      page.show 'city_results'
    end
  end

end
