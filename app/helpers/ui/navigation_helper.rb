#
# There is a lot of navigation code through crabgrass, done in really different
# ways. This helper is to bring some uniformity and sanity to how we specify
# navigation sidebars, tabs, menus, and sets of links.
#

=begin
label
icon
url
function
active
=end

module UI::NavigationHelper

  protected

  ##
  ## deprecated
  ##

  def side_list_li(options)
     active = url_active?(options[:url]) || options[:active]
     content_tag(:li, link_to_active(options[:text], options[:url], active), :class => "small_icon #{options[:icon]}_16 #{active ? 'active' : ''}")
  end

  def name_for_directory(active_tab, action)
    if active_tab == :groups
      my = I18n.t(:my_groups)
      all = I18n.t(:all_groups)
    elsif active_tab == :people
      my = I18n.t(:my_contacts)
      all = I18n.t(:all_people)
      peers = I18n.t(:my_peers)
    else
      my = I18n.t(:my_networks)
      all = I18n.t(:all_networks)
    end
    return my if action == 'my'
    return all if action == 'search'
    return peers if action == 'peers'
  end

  def url_for_directory(active_tab, action)
    type = case active_tab
           when :groups then :group
           when :people then :people
           else :network
    end
    directory_params(:type => type, :action => action)
  end


end


