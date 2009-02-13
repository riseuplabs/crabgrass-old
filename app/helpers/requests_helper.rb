module RequestsHelper

  def request_action_links(request)
    return unless  request.state == 'pending' or request.state == 'ignored'

    links = []
    links << link_to('approve'.t, {:controller => '/requests', :action => 'approve', :id => request.id}, :method => :post)
    links << link_to('reject'.t, {:controller => '/requests', :action => 'reject', :id => request.id}, :method => :post)
    if request.state == 'pending'
      links << link_to('ignore'.t, {:controller => '/requests', :action => 'ignore', :id => request.id}, :method => :post)
    end

    link_line(*links)
  end
  
  def request_destroy_link(request)
    link_to('destroy'.t, {:controller => '/requests', :action => 'destroy', :id => request.id}, :method => :post)
  end

end
