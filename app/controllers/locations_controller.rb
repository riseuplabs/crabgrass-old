class LocationsController < ApplicationController

  def all_admin_codes_options
    html = '<option value="">Choose State/Province...</option>'
    GeoCountry.find_by_id(params[:country_code]).geo_admin_codes.each do |ac|
      html << "<option value='#{ac.id}'>#{ac.name}</option>"
    end
    render :update do |page|
      page.replace_html params[:replace_id], html 
      page.show 'state_dropdown' 
      page.show 'city_text'
    end
  end

### DEPRECATED if we don't load only countries/states/cities with profiles in search form
  def countries_with_profiles_options
    html = '<option value="">Choose country...</option>'
    GeoLocation.countries_with_visible_profile.find(:all).each do |gl|
      gc = GeoCountry.find(gl.geo_country_id)
      html << "<option value='#{gc.id}'>#{gc.name}</option>"
    end
    render :update do |page|
      page.replace_html params[:replace_id], html
    end
  end

  def admin_codes_with_profiles_options
    html = '<option value="">Choose State/Province...</option>'
    GeoLocation.admin_codes_with_visible_profile(params[:country_id]).find(:all).each do |gl|
      gac = GeoAdminCode.find(gl.geo_admin_code_id)
      html << "<option value='#{gac.id}'>#{gac.name}</option>"
    end
    render :update do |page|
      page.replace_html params[:replace_id], html
      page.show 'state_dropdown'
      page.show 'submit_loc'
    end
  end

  def cities_with_profiles_options
    html = ''
    cities = []
    if params[:admin_code_id]
      options = {:country_id => params[:country_id], :admin_code_id => params[:admin_code_id]}
      GeoLocation.cities_with_visible_profile(options).find(:all).each do |gl|
        cities << GeoPlace.find(gl.geo_place_id)
      end
    else
      return
    end
    cities.each do |city|
      html << "<option value='#{city.id}'>#{city.name}</option>"
    end
    render :update do |page|
      page.replace_html params[:replace_id], html
      page.show 'city_text'
    end
  end
### /DEPRECATED

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
          html << "<li><input type='checkbox' value='#{place.id}' name='profile[city_id]' id='city_with_id_#{place.id}' />#{place.name}, #{place.geo_admin_code.name}</li>"
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
