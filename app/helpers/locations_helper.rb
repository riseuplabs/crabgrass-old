module LocationsHelper

  # <%= select('group','location', GeoCountry.find(:all).to_select(:name, :code), {:include_blank => true}) %>
  def country_dropdown(object=nil, method=nil, options={})
    name = _field_name('country_id', object, method)
    show_submit = options[:show_submit] || false 
    onchange = remote_function(
      :url => {:controller => '/locations', :action => 'all_admin_codes_options'},
      :with => "'select_state_name='+$('select_state_id').name+'&show_submit=#{show_submit}&country_code='+value",
      :loading => show_spinner('country'),
      :complete => hide_spinner('country')
    ) 
    choices = [ I18n.t(:location_country).capitalize].concat(GeoCountry.find(:all).to_select(:name, :id))
    opts = (object.nil? and method.nil? and params[:country_id]) ? {:selected => params[:country_id]} : {}
    render :partial => '/locations/country_dropdown', :locals => {:object => object, :method => method, :onchange => onchange, :name=>name, :choices => choices, :opts => opts}
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
    spinner = options[:spinner]
    onblur = remote_function(
      :url => {:controller => '/locations', :action => 'city_lookup'},
      :with => "'city_id_name='+$('city_id_field').name+'&country_id='+$('select_country_id').value+'&admin_code_id='+$('select_state_id').value+'&city='+value",
      :loading => show_spinner('city'),
      :complete => hide_spinner('city')
    )
    if params[:city_id] =~ /\d+/
      city = GeoPlace.find(params[:city_id])
    end
    value = city.nil? ? {} : {:value => city.name} 
    options = {:onblur => onblur, :name => name, :id=> 'city_text_field'}.merge(value)
    render :partial => '/locations/city_text_field', :locals => {:display => display, :object=>object, :method=>method, :options => options}
  end

  def city_id_field(object=nil, method=nil)
    name = _field_name('city_id', object, method)
    city_id =  (!@profile.nil? and @profile.city_id) ? @profile.city_id : params[:city_id] 
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
    if entity.profile.country_id and (entity.profile.country_id != 0)
      'Local-'+entity.profile.geo_location.geo_country.name
    end
  end

  private

  def _field_name(altname, object=nil, method=nil)
    if !object.nil? and !method.nil?
      object + "[#{method}]"
    else
      altname
    end
  end

  def _display_value(force=nil)
    if (@profile and @profile.country_id) or force
      'inline'
    else
      'none'
    end
  end 

end
