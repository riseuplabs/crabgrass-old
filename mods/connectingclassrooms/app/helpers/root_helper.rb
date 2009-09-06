module RootHelper

  def visit_network_link
    link_to_with_icon 'network', "Visit the network"[:welcome_visit_network_link], networks_url
  end

  def find_groups_link
    link_to_with_icon 'group', "Find groups"[:welcome_find_groups_link], groups_url
  end

  def upload_user_icon_link
    link_to_with_icon 'user_icon', "Upload a user icon"[:welcome_upload_icon_link], me_url(:action => 'edit', :id => nil)
  end

  def create_page_link
    link_to_with_icon 'page_add', "Create a new page"[:welcome_create_page_link], :controller => '/pages', :action => 'create'
  end
end
