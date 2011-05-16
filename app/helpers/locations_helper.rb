module LocationsHelper

  # <%= select('group','location', GeoCountry.find(:all).to_select(:name, :code), {:include_blank => true}) %>
  def country_dropdown(object=nil, method=nil, options={})
    profile_id_param = @profile ? "profile_id=#{@profile.id}&" : nil
    name = _field_name('country_id', object, method)
    onchange = remote_function(
      :url => {:controller => '/locations', :action => 'country_dropdown_onchange'},
      :with => "'#{profile_id_param}country_code='+value",
      :loading => show_spinner('country'),
      :complete => hide_spinner('country')
    ) 
    choices = country_choices
    render :partial => '/locations/country_dropdown', :locals => {:object => object, :method => method, :onchange => onchange, :name=>name, :choices => choices, :opts => {} }
  end

  def country_dropdown_for_search
    name = _field_name('country_id')
    update_form_for = @widget ? 'widget' : 'directory'
    onchange = remote_function(
      :url => {:controller => '/locations', :action => 'country_dropdown_onchange'},
      :with => "'update_form_for=#{update_form_for}&show_admin_codes=1&country_code='+value",
      :loading => show_spinner('country'),
      :complete => hide_spinner('country')
    )
    choices = country_choices
    opts = params[:country_id] ? {:selected => params[:country_id]} : {}
    render :partial => '/locations/country_dropdown', :locals => {:object => nil, :method => nil, :onchange => onchange, :name=>name, :choices => choices, :opts => opts}
  end

  def state_dropdown(object=nil, method=nil, country_id=nil, options={})
    display = _display_value(params[:country_id])
    html = ""
    name = _field_name('state_id', object, method)
    country_id ||= params[:country_id]
    if country_id.nil?
      geo_admin_codes = []
    else
      geocountry = GeoCountry.find_by_id(country_id)
      geo_admin_codes = geocountry.nil? ? [] : geocountry.geo_admin_codes.find(:all)
    end
    render :partial => '/locations/state_dropdown', :locals => {:geo_admin_codes => geo_admin_codes, :display => display, :name => name}
  end

  def city_text_field(object=nil, method=nil, options = {})
    display = _display_value(params[:country_id])
    name = _field_name('city_name', object, method)
    options = {:name => name, :id=> 'city_text_field'}  #.merge(value)
    if params[:city_id] and object.nil? and method.nil?
      gp = GeoPlace.find_by_id(params[:city_id])
      options.merge!({:value => gp.name}) if gp and gp.name
    end
    render :partial => '/locations/city_text_field', :locals => {:display => display, :object=>object, :method=>method, :options => options}
  end

  def city_id_field(object=nil, method=nil)
    name = _field_name('city_id', object, method)
    city_id = params[:city_id] 
    render :partial => '/locations/city_id_field', :locals => {:city_id => city_id, :name => name}
  end

  def link_to_city_id(place, city_id_name)
    link_to_city_id = link_to_remote(place.name+', '+place.geo_admin_code.name, 
      :url => {:controller => '/locations', :action => 'select_city_id'},
      :with => "'city_id=#{place.id}&city_id_name=#{city_id_name}'"
    )
  end

  def selected_admin_code(ac_id, profile=nil)
    return true if !profile.nil? and (profile.state_id == ac_id.to_s)
    return true if params[:state_id].to_i == ac_id
    return false
  end

  def friendly_location(entity)
    countries = entity.profile.geo_locations.distinct(:geo_country_id)
    countries.is_a?(Array) ?
      countries.collect!{|c| 'Local-'+c.name }.join('<br />') :
      'Local-'+countries.name  
  end

  def label_for_location(loc)
    if loc.geo_place.nil?
      return loc.geo_country.name if loc.geo_admin_code.nil?
      loc.geo_admin_code.name+', '+loc.geo_country.name
    else
      loc.geo_place.name+', '+loc.geo_admin_code.name+', '+loc.geo_country.code
    end
  end

  def geo_locations_edit_country_dropdown
    country_id = @location ? @location.geo_country_id : nil
    select_tag 'geo_location[geo_country_id]', 
                options_from_collection_for_select(GeoCountry.find(:all), 'id', 'name', country_id), 
                {:id => 'select_country_id', 
                 :onchange =>  remote_function(
                  :url => {:controller => '/locations', :action => 'country_dropdown_onchange'},
                  :with => "'update_form_for=profile&country_code='+value")
                }
  end
 
  private

  def country_choices
    [ I18n.t(:location_country).capitalize].concat(GeoCountry.find(:all).to_select(:name, :id))
  end

  def _field_name(altname, object=nil, method=nil)
    if !object.nil? and !method.nil?
      object + "[#{method}]"
    else
      altname
    end
  end

  def _display_value(country_id, force=nil)
    if country_id or force
      'inline'
    else
      'none'
    end
  end 

end
