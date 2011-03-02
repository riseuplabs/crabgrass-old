module WidgetsHelper

  def render_widget(widget)
    locals = {:widget => widget}
    locals.merge! widget.options if widget.options
    render :partial => widget.partial, :locals => locals
  end

  def list_widget(widget)
    render :partial => 'widgets/list', :locals => {
      :widget => widget
    }
  end

  def edit_widget(widget)
    locals = {:widget => widget}
    locals.merge! widget.options if widget.options
    render :partial => widget.edit_partial, :locals => locals
  end

  ##
  ## lists of active groups and users. used by the view.
  ##

  def render_active_entities(widget)
    type = widget.options[:type] || :users
    recent = widget.options[:recent] || false
    entities = get_active_entities(type, recent).find(:all, :limit => 8)
    url = view_all_url(type)
    render :partial => '/avatars/entity_boxes', :locals => {
      :entities => entities,
      :header => widget.title,
      :size => 'medium',
      :after => link_to(I18n.t(:view_all), url)
    }
  end

  def get_active_entities(type, recent)
    case type
    when :groups
      if recent
        Group.only_groups.recent_visits
      else
        Group.only_groups.most_visits
      end
    when :users
      if recent
        User.most_active_on(current_site, Time.now - 30.days).not_inactive
      else
        User.most_active_on(current_site, nil).not_inactive
      end
    end
  end

  def view_all_url(type)
    case type
    when :groups
      group_directory_path(:action => :search)
    when :users
      people_directory_path(:browse)
    end
  end

end
