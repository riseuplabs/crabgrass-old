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

  def navbar_menu(id, label, url, options={})
    menu_heading = content_tag(:span,
      link_to_active(label, url, options[:active]),
      :class => 'navbar_item'
    )
    content_tag(:li,
      [menu_heading, options[:menu_items]].combine("\n"),
      :class => ['navbar_menu', (options[:active] && 'active')].combine,
      :id => id
    )
  end

  def menu_items(partial, locals={})
    render :partial => 'layouts/menu/'+partial, :locals => locals
  end

  ##
  ## MENUS
  ##

  def menu_home
    top_menu(
      'menu_home',
      I18n.t(:menu_home),
      '/',
      :active => @active_tab == :home
    )
  end

  def menu_me
    top_menu(
      "menu_me",
      I18n.t(:menu_me),
      "/me/dashboard",
      :active => @active_tab == :me,
      :menu_items => menu_items('me')
    )
  end

  def menu_people
    top_menu(
      "menu_people",
      I18n.t(:menu_people),
      people_directory_url(:friends),
      :active => @active_tab == :people,
      :menu_items => menu_items('boxes', {
        :entities => current_user.friends.most_active,
        :heading  => I18n.t(:my_contacts),
        :see_all_url => people_directory_url(:friends),
        :submenu => 'people'
      })
    )
  end

  def menu_groups
    top_menu(
      "menu_groups",
      I18n.t(:menu_groups),
      group_directory_url,
      :active => @active_tab == :groups,
      :menu_items => menu_items('boxes', {
        :entities => current_user.primary_groups.most_active,
        :heading => I18n.t(:my_groups),
        :see_all_url => group_directory_url(:action => 'my'),
        :submenu => 'groups'
      })
    )
  end

  def menu_networks
    top_menu(
      "menu_networks",
      I18n.t(:menu_networks),
      network_directory_url,
      :active => @active_tab == :networks,
      :menu_items => menu_items('boxes', {
        :entities => current_user.primary_networks.most_active,
        :heading => I18n.t(:my_networks),
        :see_all_url => network_directory_url(:action => 'my'),
        :submenu => 'networks'
      })
    )
  end

  def menu_chat
    top_menu "menu_chat", I18n.t(:menu_chat), '/chat', :active => @active_tab == :chat
  end

  def menu_admin
    top_menu "menu_admin", I18n.t(:menu_admin), '/admin', :active => @active_tab == :admin
  end
end
