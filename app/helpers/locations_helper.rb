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
    render :partial => '/locations/country_dropdown', :locals => {:object => object, :method => method, :onchange => onchange, :name=>name}
  end

  def state_dropdown(object=nil, method=nil, country_id=nil, options={})
    display = _display_value
    html = ""
    name = _field_name('state_id', object, method)
    if country_id.nil?
      geo_admin_codes = []
    else
      geocountry = GeoCountry.find_by_id(country_id)
      geo_admin_codes = geocountry.geo_admin_codes.find(:all)
    end
    render :partial => '/locations/state_dropdown', :locals => {:geo_admin_codes => geo_admin_codes, :display => display, :name => name}
  end

  def city_text_field(object=nil, method=nil, options = {})
    display = _display_value
    name = _field_name('city_name', object, method)
    spinner = options[:spinner]
    onblur = remote_function(
      :url => {:controller => '/locations', :action => 'city_lookup'},
      :with => "'city_id_name='+$('city_id_field').name+'&country_id='+$('select_country_id').value+'&admin_code_id='+$('select_state_id').value+'&city='+value",
      :loading => show_spinner('city'),
      :complete => hide_spinner('city')
    )
    render :partial => '/locations/city_text_field', :locals => {:display => display, :name => name, :onblur => onblur, :object=>object, :method=>method}
  end

  def city_id_field(object=nil, method=nil)
    name = _field_name('city_id', object, method)
    city_id =  (!@profile.nil? and @profile.city_id) ? @profile.city_id : ''
    render :partial => '/locations/city_id_field', :locals => {:city_id => city_id, :name => name}
  end

  def link_to_city_id(place, city_id_name)
    link_to_city_id = link_to_remote(place.name+', '+place.geo_admin_code.name, 
      :url => {:controller => '/locations', :action => 'select_city_id'},
      :with => "'city_id=#{place.id}&city_id_name=#{city_id_name}'"
    )
  end

  def selected_admin_code(ac_id, profile=nil)
    return false if profile.nil?
    true if profile.state_id == ac_id.to_s
  end

#####
##### should be removed if we end up not limiting dropdown in directory search to countries/states with profiles
#####
#  def select_search_countries(replace_id)
#    onchange = remote_function(
#      :url => {:controller => '/locations', :action => 'admin_codes_with_profiles_options'},
#      :with => "'country_id='+value+'&replace_id=#{replace_id}'"
#    )
#    countries_with_groups = []
#    @groups.each do |gr|
#      if gr.profile.geo_location
#        countries_with_groups.push(GeoCountry.find(gr.profile.geo_location.geo_country_id))
#      end
#    end
#    select(nil, nil, '', {:include_blank=>true}, {:name=>'country_id', :id=> 'select_country_id', :onchange => onchange})
#  end
#
#  def select_search_admin_codes(select_state_id, replace_id)
#    onchange = remote_function(
#      :url => {:controller => '/locations', :action => 'cities_with_profiles_options'},
#      :with => "'country_id='+$('select_country_id').value+'&admin_code_id='+value+'&replace_id=#{replace_id}'"
#    )
#    select(nil, nil, '', {:include_blank => true}, {:id => select_state_id, :onchange => onchange})
#  end
#####
##### end should be removed
#####

  def _field_name(altname, object=nil, method=nil)
    if !object.nil? and !method.nil?
      object + "[#{method}]"
    else
      altname
    end
  end

  def _display_value
    if @profile and @profile.country_id
      'inline'
    else
      'none'
    end
  end 

end
