module Admin::PagesHelper

  def pages_path(arg, options={})
    admin_pages_path(arg,options)
  end

  def edit_pages_path(arg)
    edit_admin_pages_path(arg)
  end
 
  def new_pages_path
    new_admin_pages_path
  end

  def pages_path
    admin_pages_path
  end

  def pages_url(arg, options={})
    admin_pages_url(arg, options)
  end

  def page_moderation_navigation_links
    links = []
#    links << link_to_active( 'pending', :controller => 'admin/pages', :action => 'index', :view => 'pending')
    
    links << "Flagged Pages:"
    links << link_to_active( 'new', :controller => 'admin/pages', :action => 'index', :view => 'new')
    links << link_to_active( 'vetted',  :controller => 'admin/pages', :action => 'index', :view => 'vetted')
    links << link_to_active( 'deleted', :controller => 'admin/pages', :action => 'index', :view => 'deleted')

    links << "Request to Make Public:"
    links << link_to_active( 'requested', :controller => 'admin/pages', :action => 'index', :view => 'public requested')
    links << link_to_active( 'approved', :controller => 'admin/pages', :action => 'index', :view => 'public')
    content_tag(:div,
                links.join('&nbsp;'),
                :style => 'padding-bottom: 1em')
  end

end


