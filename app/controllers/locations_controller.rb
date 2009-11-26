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

  def city_lookup
    html = ''
    country_id = params[:country_id]
    admin_code_id = params[:admin_code_id]
    city = params[:city]
    if country_id.empty? or city.empty?
      html << 'Country and City are both required.'
    else
      geocountry = GeoCountry.find_by_id(country_id)
      ### this should move to the model
      if admin_code_id.empty?
        admin_codes = geocountry.geo_admin_codes
      else
        admin_code = geocountry.geo_admin_codes.find_by_id(admin_code_id)
        admin_codes = [admin_code]
      end
      ####
      html << '<ul>'
      admin_codes.each do |ac|
        places = ac.geo_places.find_by_name(city)
        if places.is_a?(Array)
          places.each do |place|
            html << "<li><input type='checkbox' value='#{place.id}' name='profile[city_id]' />#{place.name}, #{place.geo_admin_code.name}</li>"
          end
        elsif ! places.nil?
          html << "<li><input type='checkbox'  value='#{places.id}' name='profile[city_id]' 'selected' />#{places.name}, #{places.geo_admin_code.name}</li>"
        end
      end
      html << '</ul>'
    end
    render :update do |page|
      page.replace_html 'city_results', html
      page.show 'city_results'
    end
  end

end
