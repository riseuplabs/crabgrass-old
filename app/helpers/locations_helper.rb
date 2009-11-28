module LocationsHelper

  # <%= select('group','location', GeoCountry.find(:all).to_select(:name, :code), {:include_blank => true}) %>
  def country_dropdown(object=nil, method=nil)
    onchange = remote_function(
      :url => {:controller => '/locations', :action => 'replace_admin_codes_options'},
      :with => "'replace_id=geo_state_id&country_code='+value",
      :loading => add_class_name('geo_country_id', 'spinner_icon'),
      :complete => remove_class_name('geo_country_id','spinner_icon')
    ) 
    select(object,method, GeoCountry.find(:all).to_select(:name, :id), {:include_blank => true},{:id => 'geo_country_id', :onchange => onchange})
  end

  def state_dropdown(object=nil, method=nil, country_id=nil)
    if country_id.nil?
      select(object, method, '', {:include_blank => true}, {:name=>'state_id', :id=>'select_state_id'})
    else
      geocountry = GeoCountry.find_by_id(country_id)
      select(object, method, geocountry.geo_admin_codes.find(:all).to_select(:name, :id), {:include_blank=>true}, {:id => 'geo_state_id'})
    end
  end

  def city_text_field(object=nil, method=nil)
    onblur = remote_function(
      :url => {:controller => '/locations', :action => 'city_lookup'},
      :with => "'country_id='+$('geo_country_id').value+'&admin_code_id='+$('geo_state_id').value+'&city='+value"
    )
    text_field(object, method, {:onblur => onblur})
  end

  def select_search_countries
    onchange = remote_function(
      :url => {:controller => '/locations', :action => 'show_search_admin_codes'},
      :with => "'country_id='+value"
    )
    select(nil, nil, GeoCountry.with_public_profile.find(:all).to_select(:name, :id), {:include_blank=>true}, {:name=>'country_id', :id=> 'select_country_id', :onchange => onchange})
  end

end
