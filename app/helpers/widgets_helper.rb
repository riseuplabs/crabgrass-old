module WidgetsHelper

  def render_widget(widget)
    locals = {:widget => widget}
    locals.merge! widget.options if widget.options
    render :partial => widget.partial, :locals => locals
  end

  def edit_widget(widget)
    locals = {:widget => widget}
    locals.merge! widget.options if widget.options
    render :partial => widget.edit_partial, :locals => locals
  end

  def edit_widget_link(widget)
    #link_to I18n.t(:edit), edit_admin_widget_path(widget)
    # link_to_remote I18n.t(:edit),
    #  :url => edit_admin_widget_path(widget),
    #  :method => :get
    link_to_modal('edit', {:url => edit_widget_url(widget), :title => widget.title})
  end

  def preview_widget_link(widget)
    #link_to_remote I18n.t(:preview),
    #  :url => admin_widget_path(widget),
    #  :method => :get
    link_to_modal('preview', {:url => widget_url(widget), :title => widget.title})
  end

  ##
  ## lists of active groups and users. used by the view.
  ##

  def get_active_entities(widget)
    type = widget.options[:type] || :users
    recent = widget.options[:recent] || false
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
