module WidgetsHelper

  def render_widget(widget)
    render :partial => widget.partial,
      :locals => widget.options.merge!({:widget => widget})
  end

  def list_widget(widget)
    render :partial => 'widgets/list', :locals => {
      :widget => widget
    }
  end

  def edit_widget(widget)
    render :partial => widget.edit_partial,
      :locals => widget.options.merge!({:widget => widget})
  end

  ##
  ## lists of active groups and users. used by the view.
  ##

  def most_active_groups
    Group.only_groups.most_visits.find(:all, :limit => 15)
  end

  def recently_active_groups
    Group.only_groups.recent_visits.find(:all, :limit => 10)
  end

  def most_active_users
    User.most_active_on(current_site, nil).not_inactive.find(:all, :limit => 15)
  end

  def recently_active_users
    User.most_active_on(current_site, Time.now - 30.days).not_inactive.find(:all, :limit => 10)
  end

end
