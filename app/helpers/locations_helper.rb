module LocationsHelper

  # <%= select('group','location', GeoCountry.find(:all).to_select(:name, :code), {:include_blank => true}) %>
  def country_dropdown(object=nil, method=nil, select_id='select_country_id', replace_id='select_state_id')
    name = _field_name('country_id', object, method)
    onchange = remote_function(
      :url => {:controller => '/locations', :action => 'all_admin_codes_options'},
      :with => "'replace_id=#{replace_id}&country_code='+value"
#      :loading => add_class_name('geo_country_id', 'spinner_icon'),
#      :complete => remove_class_name('geo_country_id','spinner_icon')
    ) 
    select(object,method, GeoCountry.find(:all).to_select(:name, :id), {:include_blank => true},{:name => name, :id => select_id, :onchange => onchange})
  end

  def state_dropdown(object=nil, method=nil, country_id=nil, select_id='select_state_id')
    name = _field_name('state_id', object, method)
    if country_id.nil?
      select(object, method, '', {:include_blank => true}, {:id=>select_id})
    else
      geocountry = GeoCountry.find_by_id(country_id)
      select(object, method, geocountry.geo_admin_codes.find(:all).to_select(:name, :id), {:include_blank=>true}, {:name => name, :id => select_id})
    end
  end

  def city_text_field(object=nil, method=nil, country_select_id='select_country_id', state_select_id='select_state_id')
    name = _field_name('city_id', object, method)
    onblur = remote_function(
      :url => {:controller => '/locations', :action => 'city_lookup'},
      :with => "'country_id='+$('#{country_select_id}').value+'&admin_code_id='+$('#{state_select_id}').value+'&city='+value"
    )
    text_field(object, method, {:onblur => onblur, :name => name})
  end

  def city_id_field
    html = ''
    contents = ''
    if @profile.city_id
      contents << '<ul>'
      contents << "<li><input type='checkbox' value='#{@profile.city_id}' name='profile[city_id]' id='city_with_id_#{@profile.city_id}' 'checked' />#{@profile.geo_city_name}</li>"
      contents << '</ul>'
      display = "inline"
    else
      display = "none"
    end
    html << "<div id='city_results' style='display:#{display}'>"
    html << contents + "</div>"
  end

  def select_search_countries(replace_id)
    onchange = remote_function(
      :url => {:controller => '/locations', :action => 'admin_codes_with_profiles_options'},
      :with => "'country_id='+value+'&replace_id=#{replace_id}'"
    )
#    countries_with_groups = []
#    @groups.each do |gr|
#      if gr.profile.geo_location
#        countries_with_groups.push(GeoCountry.find(gr.profile.geo_location.geo_country_id))
#      end
#    end
    select(nil, nil, '', {:include_blank=>true}, {:name=>'country_id', :id=> 'select_country_id', :onchange => onchange})
  end

  def select_search_admin_codes(select_state_id, replace_id)
    onchange = remote_function(
      :url => {:controller => '/locations', :action => 'cities_with_profiles_options'},
      :with => "'country_id='+$('select_country_id').value+'&admin_code_id='+value+'&replace_id=#{replace_id}'"
    )
    select(nil, nil, '', {:include_blank => true}, {:id => select_state_id, :onchange => onchange})
  end

  def _field_name(altname, object=nil, method=nil)
    if !object.nil? and !method.nil?
      object + "[#{method}]"
    else
      altname
    end
  end

end
