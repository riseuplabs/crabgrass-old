module Admin::WidgetsHelper

  def edit_widget_link(widget)
    #link_to I18n.t(:edit), edit_admin_widget_path(widget)
    # link_to_remote I18n.t(:edit),
    #  :url => edit_admin_widget_path(widget),
    #  :method => :get
    link_to_modal('edit', {:url => edit_admin_widget_path(widget), :title => widget.title})
  end

  def preview_widget_link(widget)
    #link_to_remote I18n.t(:preview),
    #  :url => admin_widget_path(widget),
    #  :method => :get
    link_to_modal('preview', {:url => admin_widget_path(widget), :title => widget.title})
  end

end
