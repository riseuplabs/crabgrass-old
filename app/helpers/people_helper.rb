module PeopleHelper
  def people_navigation_links
    links = []
    links << link_to_active( :new_people_link.t, :controller => 'people' )
    if logged_in?
      links << link_to_active( :my_contacts_link.t, :controller => 'people', :action => 'contacts' )
      links << link_to_active( :my_peers_link.t, :controller => 'people', :action => 'peers' )
    end
    links << link_to_active( :all_people_link.t, :controller => 'people', :action => 'directory' )
    content_tag(:div, link_line(*links), :class => 'navigation')
  end
end
