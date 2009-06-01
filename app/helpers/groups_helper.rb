module GroupsHelper

  def groups_navigation_links
    return unless logged_in?
    links = []
    if logged_in?
      links << link_to_with_icon('plus', "Create a new {thing}"[:create_a_new_thing, :group.t.downcase], :controller => 'groups', :action => 'create')
    end
    links << link_to_active( 'new groups'[:new_groups_link], :controller => 'groups', :action => 'index' )
    if logged_in?
      links << link_to_active( 'my groups'[:my_groups_link], :controller => 'groups', :action => 'my' )
    end
    links << link_to_active( 'group directory'[:group_directory_link], :controller => 'groups', :action => 'directory' )
    content_tag(:div, link_line(*links), :class => 'navigation')
  end

end
