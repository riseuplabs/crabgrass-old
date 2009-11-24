class LocationsController < ApplicationController

  def replace_admin_codes_options
    html = ''
    GeoCountry.find_by_id(params[:country_code]).geo_admin_codes.each do |ac|
      html << "<option value='#{ac.id}'>#{ac.name}</option>"
    end
    render :update do |page|
      page.replace_html 'group_state', html 
    end
  end

end
