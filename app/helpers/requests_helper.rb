module RequestsHelper

  def request_action_links(request)
    if request.state == 'pending'
      link_line(
        link_to('approve'.t, {:controller => '/requests', :action => 'approve', :id => request.id}, :method => :post),
        link_to('reject'.t, {:controller => '/requests', :action => 'reject', :id => request.id}, :method => :post)
      )
    end
  end
  
  def request_destroy_link(request)
    link_to('destroy'.t, {:controller => '/requests', :action => 'destroy', :id => request.id}, :method => :post)
  end

  def expand_description(request)
    request.description.gsub(/<span class="user">(.*?)<\/span>/) do |match|
      link_to_user($1)
    end.gsub(/<span class="group">(.*?)<\/span>/) do |match|
      link_to_group($1)
    end
  end

end
