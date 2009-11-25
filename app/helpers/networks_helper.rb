module NetworksHelper
  def networks_navigation_links
    links = []
    if logged_in?
      links << link_to_with_icon('plus', I18n.t(:create_a_new_thing, :thing => I18n.t(:network).downcase), :controller => 'networks', :action => 'create')
      links << link_to_active( I18n.t(:my_networks_link), :controller => 'networks', :action => 'my' )
    end

    links << link_to_active( I18n.t(:network_directory_link), :controller => 'networks', :action => 'list' )

    content_tag(:div, link_line(*links), :class => 'navigation')
  end
end
