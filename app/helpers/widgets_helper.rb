module WidgetsHelper

  def render_widget(widget)
    locals = {:widget => widget}
    render :partial => widget.partial, :locals => locals
  end

  def edit_widget(widget)
    locals = {:widget => widget}
    render :partial => widget.edit_partial,
      :locals => locals
  end

  def edit_widget_link(widget)
    #link_to I18n.t(:edit), edit_admin_widget_path(widget)
    # link_to_remote I18n.t(:edit),
    #  :url => edit_admin_widget_path(widget),
    #  :method => :get
    link_to_modal '',
      :url => edit_widget_url(widget),
      :title => escape_javascript(widget.title_or_name),
      :icon => 'pencil'
  end

  def preview_widget_link(widget)
    #link_to_remote I18n.t(:preview),
    #  :url => admin_widget_path(widget),
    #  :method => :get
    link_to_modal(widget.short_title, {:url => widget_url(widget), :title => widget.title})
  end

  def destroy_widget_link(widget)
    link_to I18n.t(:destroy_widget), widget_path(widget),
      :confirm => "Are you sure you want to delete this widget?",
      :method => 'delete',
      :class => 'destroy'
  end

  def new_widget_link(section = nil, text = I18n.t(:add_button), html_options = nil)
    url = (section == :sidebar) ? sidebar_new_widget_url : new_widget_url
    html_options ||= { :class => 'right new' }
    link_to_modal text,
      { :url => url, :title => I18n.t(:create_widget)},
      html_options
  end

  def create_widget_link(section, name)
    link_params = {:section => "'#{section}'",
      :name => "'#{name}'",
      :step => '1',
      :authenticity_token => "'#{form_authenticity_token}'"}
    link_to_modal name,
      :url => widgets_url,
      :params => link_params,
      :method => 'post'
  end

  def sortable_list(section, storage = false)
    element = "sort_list_#{section}"
    containment = [element, "#{element}_storage"]
    element += "_storage" if storage
    sortable_element element,
      :url => { :action => :sort },
      :containment => containment,
      :dropOnEmpty => true
  end


  ##
  ## lists of active groups and users. used by the view.
  ##

  def get_active_entities(widget)
    entities = widget.options[:entities] || 'Users'
    recent = widget.options[:recent] == '1'
    case entities
    when 'Groups'
      if recent
        Group.only_groups.recent_visits
      else
        Group.only_groups.most_visits
      end
    else
      if recent
        User.most_active_on(current_site, Time.now - 30.days).not_inactive
      else
        User.most_active_on(current_site, nil).not_inactive
      end
    end
  end

  def view_all_url(entities)
    case entities
    when 'Groups'
      group_directory_path(:action => :search)
    else
      people_directory_path(:browse)
    end
  end

  # map widget helpers
  def map_widget_layers(widget)
    case widget.kml
    when 'groups'
      {"All groups" => '/geo_locations.kml'}
    when 'custom'
      {"Custom Layer" => widget.custom_kml}
    when 'by_network'
      layers = widget.menu_items.map do |item|
        [item.title, item.link + '/geo_locations.kml']
      end
      Hash[*layers.flatten]
    end
  end

  def map_widget_options(widget)
    return {} unless widget.map_center_latitude and widget.map_center_longitude
    zoomlevels = {
      'Global' => 2,
      'Continent' => 3,
      'Country Region' => 4,
      'Local Region' => 5,
      'Local' => 6 }
    options = {}
    options[:mapcenterlong] = widget.map_center_longitude
    options[:mapcenterlat] = widget.map_center_latitude
    options[:override_stylesheet] = 'map.css'
    options[:zoomlevel] = zoomlevels[widget.zoomlevel || 'Global']
    return options
  end

  def current_map_center(widget)
    lat = widget.map_center_latitude
    long = widget.map_center_longitude
    return '' unless lat and long
    return unless place = GeoPlace.find_by_latitude_and_longitude(lat, long)
    admin_code_name = (place.try(:geo_admin_code) and place.geo_admin_code.name) || ''
    return content_tag('div', 'Current map center: '+h(place.name)+', '+h(admin_code_name)+' '+h(place.geo_country.code))
  end

  def select_field_for_map_zoomlevel(widget)
    options = ['Global', 'Continent', 'Country Region', 'Local Region', 'Local']
    zoomlevel = widget.zoomlevel || 'Global'
    select_tag('widget[zoomlevel]', options_for_select(options, zoomlevel))
  end

  # button icon helpers
  def available_button_icons(widget)
    name = widget.name
    Conf.widgets[name][:available_icons]
  end

end
