module PeopleHelper
  def people_navigation_links
    links = []
    links << link_to_active( :directory_of_people.t, :controller => 'people' )
    if logged_in?
      links << link_to_active( :my_contacts.t, :controller => 'people', :action => 'contacts' )
      links << link_to_active( :my_peers.t, :controller => 'people', :action => 'peers' )
    end
    links << link_to_active( :all_people.t, :controller => 'people', :action => 'users' )
    content_tag(:div, link_line(*links), :class => 'navigation')
  end
end
