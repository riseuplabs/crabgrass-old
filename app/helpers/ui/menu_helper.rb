#
# Helper methods for drawing the top navigation menus
#
# Available to all views
#
module UI::MenuHelper

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

=begin
  def top_menu(label, url, options={})
    id = options.delete(:id)
    #menu_heading = content_tag(:span,
    #  link_to_active(label, url, options[:active]),
    #  :class => 'menu_title'
    #)
    menu_heading = link_to_active(label, url, options[:active], :class => 'tab')
    content_tag(:li,
      [menu_heading, options[:menu_items]].combine("\n"),
      :class => 'tab',
      :id => id
    )
  end

#  def navbar_menu(id, label, url, options={})
#    menu_heading = content_tag(:span,
#      link_to_active(label, url, options[:active]),
#      :class => 'navbar_item'
#    )
#    content_tag(:li,
#      [menu_heading, options[:menu_items]].combine("\n"),
#      :class => ['navbar_menu', (options[:active] && 'active')].combine,
#      :id => id
#    )
#  end

  def menu_items(partial, locals={})
    render :partial => 'layouts/headers/menu/'+partial, :locals => locals
  end


  ## *NEWUI
  ##
  ## MENUS
  ##
  ## use url as a path or as an array of paths, if you provide an array of paths
  ## the first item will be the destination url, the rest are used to highlight the
  ## tab if is needed
#  def menu(label, url, options={})
#    active = options.delete(:active) if options.has_key?(:active)

#    ### PLEASE if you change this make sure it doesn't break menus elsewhere, for example:
#    ### people directory, group directory, group pages, etc.
#    if url.is_a?(String) or url.is_a?(Hash)
#      active = url_for(url) =~ /^#{Regexp.escape(request.path)}$/i if active.nil?
#    elsif url.is_a?(Array)
#      active = !url.select { |path| url_for(path).match(/^#{Regexp.escape(request.path)}$/i) ? true : false }.empty? if !active
#      url = url.first
#    else
#      active = false if active.nil?
#    end

#    selected_class = active ? (options[:selected_class] || 'current') : ''
#    li_options = options.merge({:class => [options.delete(:class), selected_class].join(' ')})

#    content_tag(:li,
#      link_to(label, url, options), li_options
#    )
#  end

#  # returns :active option for menu() above
#  def active_tab_for_nav(level_nav, action)
#    level_nav == action ? {:active => true} : {:active => false}
#  end

  def home_option
    top_menu(
      I18n.t(:menu_home),
      '/',
      {
        :active => menu_tab == :home,
        :id => 'menu_home'
      }
    )
  end

  def me_option
    top_menu(
      I18n.t(:menu_me),
      "/pages/my_work",
      :active => menu_tab == :me,
      :menu_items => menu_items('me'),
      :id => 'menu_me'
    )
  end

  def people_option
    top_menu(
      I18n.t(:menu_people),
      '/people/directory',
      :active => menu_tab == :people,
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
      :active => menu_tab == :groups,
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
      :active => menu_tab == :networks,
      :menu_items => menu_items('boxes', {
        :entities => current_user.primary_networks.most_active(@current_site),
        :heading => I18n.t(:my_networks),
        :see_all_url => network_directory_url(:action => 'my'),
        :submenu => 'networks'
      }),
      :id => 'menu_networks'
    )
  end

  def chat_option
    menu I18n.t(:menu_chat), '/chat', :active => menu_tab == :chat, :id => 'menu_chat'
  end

  def admin_option
    top_menu I18n.t(:menu_admin), '/admin', :active => menu_tab == :admin, :id => 'menu_admin'
  end

  # i can't get the last of the top nav menus to render correctly in webkit.
  # this dummy_menu makes it so that the last menu is invisible, so the other
  # ones look fine.
  def dummy_menu
    '<li class="menu"><a class="tab"> </a></li>'
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

  # haml helper to prevent emptly list items
  # example:
  # =li_if destroy_group_link
  # will wrap the destroy group link in a li tag if it exists.
#  def li_if content
#    content_tag(:li, content) if content
#  end

  # for social activities drop down link_to_remote tag
#  def link_to_more_social_activities(toggle='more', count_diff='10')
#    return unless count_diff > 0
#    link_s = (toggle == 'more') ? I18n.t(:see_count_more_link, :count => count_diff) : I18n.t(:see_count_less_link, :count => count_diff)
#    link_to_remote link_s, 
#      :url => {:controller => '/me/social_activities', :see => toggle},
#      :loading => show_spinner('more_socials'),
#      :complete => hide_spinner('more_socials'),
#      :method => 'GET'
#  end

  private

  # returns the symbol for the top menu tab
  def menu_tab
    @context ? @context.tab : @active_tab
  end
=end

end
