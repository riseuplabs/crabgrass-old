module NetworksHelper
  def networks_navigation_links
    links = []
    if logged_in?
      links << link_to_with_icon('plus', "Create a new {thing}"[:create_a_new_thing, :network.t.downcase], :controller => 'networks', :action => 'create')
      links << link_to_active( 'my networks'[:my_networks_link], :controller => 'networks', :action => 'my' )
    end

    links << link_to_active( 'network directory'[:network_directory_link], :controller => 'networks', :action => 'list' )

    content_tag(:div, link_line(*links), :class => 'navigation')
  end
end
