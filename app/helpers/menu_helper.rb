#
# Helper methods for drawing the top navigation menus
#
# Available to all views
#
module MenuHelper

  def top_menu(id, label, url, options={})
    menu_heading = content_tag(:span,
      link_to_active(label, url, options[:active]),
      :class => 'topnav'
    )
    content_tag(:li,
      [menu_heading, options[:menu_items]].combine("\n"),
      :class => ['menu', (options[:active] && 'active')].combine,
      :id => id
    )
  end

  def menu_items(partial, locals={})
    render :partial => 'layouts/menu/'+partial, :locals => locals
  end

end
