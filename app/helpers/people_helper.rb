module PeopleHelper
  def people_navigation_links
    links = []
    links << link_to_active( I18n.t(:new_people_link), :controller => 'people' )
    if logged_in?
      links << link_to_active( I18n.t(:my_contacts_link), :controller => 'people', :action => 'contacts' )
      links << link_to_active( I18n.t(:my_peers_link), :controller => 'people', :action => 'peers' )
    end
    links << link_to_active( I18n.t(:all_people_link), :controller => 'people', :action => 'directory' )
    content_tag(:div, link_line(*links), :class => 'navigation')
  end

  def user_line(user, profile)
    if profile.may_see?
      link_to "#{user.login}", url_for_user(user)
    else
      h user.login
    end
  end
end
