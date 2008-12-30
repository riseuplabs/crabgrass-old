module Admin::PostsHelper

  def posts_path(arg, options={})
    admin_posts_path(arg,options)
  end

  def edit_posts_path(arg)
    edit_admin_posts_path(arg)
  end
 
  def new_posts_path
    new_admin_posts_path
  end

  def posts_path
    admin_posts_path
  end

  def posts_url(arg, options={})
    admin_posts_url(arg, options)
  end

  def post_moderation_navigation_links
    links = []
    links << link_to_active( 'pending', :controller => 'admin/posts', :action => 'index', :view => 'pending')
    links << link_to_active( 'vetted',  :controller => 'admin/posts', :action => 'index', :view => 'vetted')    
	links << link_to_active( 'deleted', :controller => 'admin/posts', :action => 'index', :view => 'deleted')
	links << link_to_active( 'new', :controller => 'admin/posts', :action => 'index', :view => 'new')
    content_tag(:div, link_line(*links), :style => 'padding-bottom: 1em')
  end

end


