module NetworksHelper
  def networks_navigation_links
    links = []
    links << link_to_active( 'network directory'[:network_directory_link], :controller => 'networks', :action => 'list' )
    content_tag(:div, link_line(*links), :class => 'navigation')
  end
end
