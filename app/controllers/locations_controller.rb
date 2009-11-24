class LocationsController < ApplicationController

  def replace_admin_codes_options
    html = ''
    GeoCountry.find_by_code(params[:country_code]).geo_admin_codes.each do |ac|
      html << "<option value='#{ac.admin1_code}'>#{ac.name}</option>"
    end
    render :update do |page|
      page.replace_html 'group_state', html 
    end
  end

end
