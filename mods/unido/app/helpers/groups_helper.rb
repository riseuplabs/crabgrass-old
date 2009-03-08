module GroupsHelper
  def groups_navigation_links
    return unless logged_in?
    links = []
    if logged_in?
      links << link_to_active( 'my groups'[:my_groups_link], :controller => 'groups', :action => 'my' )
    end
    links << link_to_active( 'group directory'[:group_directory_link], :controller => 'groups', :action => 'directory' )
    content_tag(:div, link_line(*links), :class => 'navigation')
  end
end

