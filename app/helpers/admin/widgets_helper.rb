module Admin::WidgetsHelper

  def edit_widget_link(widget)
    link_to I18n.t(:edit), edit_admin_widget_path(widget)
    # link_to_remote I18n.t(:edit),
    #  :url => edit_admin_widget_path(widget),
    #  :method => :get
  end

  def preview_widget_link(widget)
    link_to I18n.t(:preview), admin_widget_path(widget)
    # link_to_remote I18n.t(:preview),
    #  :url => admin_widget_path(widget),
    #  :method => :get
  end

end
