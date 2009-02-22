module GroupsHelper

  def groups_navigation_links
    return unless logged_in?
    links = []
    if logged_in?
      :create_a_new_thing.t % {:thing => 'network'.t}
      links << link_to_icon( :create_a_new_thing.t % {:thing => 'group'.t}, 'actions/plus.png', :controller => 'groups', :action => 'create' )

      # links << link_to_icon( 'create a new group'[:create_group_link], 'actions/plus.png', :controller => 'groups', :action => 'create' )
    end
    links << link_to_active( 'new groups'[:new_groups_link], :controller => 'groups', :action => 'index' )
    if logged_in?
      links << link_to_active( 'my groups'[:my_groups_link], :controller => 'groups', :action => 'my' )
    end
    links << link_to_active( 'group directory'[:group_directory_link], :controller => 'groups', :action => 'directory' )
    content_tag(:div, link_line(*links), :class => 'navigation')
  end

  def groups_available_pagination_letters(groups)
    pagination_letters = []
    groups.each do |g|
      pagination_letters << g.full_name.first.upcase if g.full_name
      pagination_letters << g.name.first.upcase if g.name
    end

    return pagination_letters.uniq!
  end

end
