#
# Helper methods for drawing the top navigation menus
#
# Available to all views
#
module MenuHelper

  def top_menu(label, url, options={})
    id = options.delete(:id)
    menu_heading = content_tag(:span,
      link_to_active(label.upcase, url, options[:active]),
      :class => 'topnav'
    )
    content_tag(:li,
      [menu_heading, options[:menu_items]].combine("\n"),
      :class => ['menu', (options[:active] && 'current')].combine,
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

  ## *NEWUI
  ##
  ## MENUS
  ##
  def menu(label, url, options={})
    active = options.has_key?(:active) ? options[:active] : (url_for(url) =~ /#{request.path}/i)
    selected_class = active ? (options[:selected_class] || 'current') : ''
    content_tag(:li,
      link_to(label.upcase, url, options),
      options.merge(
        { :class => [options[:class], selected_class].join(' ')})
    )
  end

  # returns :active option for menu() above
  def active_tab_for_nav(level_nav, action)
    level_nav == action ? {:active => true} : {:active => false}
  end

  def home_option
    top_menu(
      I18n.t(:menu_home),
      '/',
      {
        :active => @active_tab == :home,
        :id => 'menu_home'
      }
    )
  end

  def me_option
    top_menu(
      I18n.t(:menu_me),
      "/pages/my_work",
      :active => @active_tab == :me,
      :menu_items => menu_items('me'),
      :id => 'menu_me'
    )
  end

  def people_option
    top_menu(
      I18n.t(:menu_people),
      people_directory_url(:friends),
      :active => @active_tab == :people,
      :menu_items => menu_items('boxes', {
        :entities => current_user.friends.most_active,
        :heading  => I18n.t(:my_contacts),
        :see_all_url => people_directory_url(:friends),
        :submenu => 'people'
      }),
      :id => 'menu_people'
    )
  end

  def groups_option
    top_menu(
      I18n.t(:menu_groups),
      group_directory_url,
      :active => @active_tab == :groups,
      :menu_items => menu_items('boxes', {
        :entities => current_user.primary_groups.most_active,
        :heading => I18n.t(:my_groups),
        :see_all_url => group_directory_url(:action => 'my'),
        :submenu => 'groups'
      }),
      :id => 'menu_groups'
    )
  end

  def networks_option
    top_menu(
      I18n.t(:menu_networks),
      network_directory_url,
      :active => @active_tab == :networks,
      :menu_items => menu_items('boxes', {
        :entities => current_user.primary_networks.most_active,
        :heading => I18n.t(:my_networks),
        :see_all_url => network_directory_url(:action => 'my'),
        :submenu => 'networks'
      }),
      :id => 'menu_networks'
    )
  end

  def chat_option
    menu I18n.t(:menu_chat), '/chat', :active => @active_tab == :chat, :id => 'menu_chat'
  end

  def admin_option
    top_menu I18n.t(:menu_admin), '/admin', :active => @active_tab == :admin, :id => 'menu_admin'
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

  def split_entities_into_columns(entities)
    entities.sort! {|a,b| a.name <=> b.name}
    cols = {}
    if entities.size > 3
      half = entities.size/2.round
      cols[:right_col] = entities.slice!(-half, half)
      cols[:left_col] = entities
    else
      cols[:left_col] = entities
      cols[:right_col] = []
    end
    return cols
  end

end
