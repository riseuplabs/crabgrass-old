module LocationsHelper

  # <%= select('group','location', GeoCountry.find(:all).to_select(:name, :code), {:include_blank => true}) %>
  def country_dropdown(object, method)
    onchange = remote_function(
      :url => {:controller => '/locations', :action => 'replace_admin_codes_options'},
      :with => "'replace_id=profile_state_id&country_code='+value",
      :loading => add_class_name('profile_country_id', 'spinner_icon'),
      :complete => remove_class_name('profile_country_id','spinner_icon')
    ) 
    select(object,method, GeoCountry.find(:all).to_select(:name, :id), {:include_blank => true},{:onchange => onchange})
  end

  def state_dropdown(object, method, country_id=nil)
    if country_id.nil?
      select(object, method, '', {:include_blank => true})
    else
      geocountry = GeoCountry.find_by_id(country_id)
      select(object, method, geocountry.geo_admin_codes.find(:all).to_select(:name, :id), {:include_blank=>true})
    end
  end

  def city_text_field(object, method)
    onblur = remote_function(
      :url => {:controller => '/locations', :action => 'city_lookup'},
      :with => "'country_id='+$('profile_country_id').value+'&admin_code_id='+$('profile_state_id').value+'&city='+value"
    )
    text_field(object, method, {:onblur => onblur})
  end

end
