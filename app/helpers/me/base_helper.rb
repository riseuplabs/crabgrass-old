module Me::BaseHelper
  
  def pending_request_link
    s = @request_count == 1 ? '' : 's'
    link_to '%s pending request%s'.t % [@request_count, s],
      :controller => 'requests'
  end

  def unread_inbox_link
    s = @unread_count == 1 ? '' : 's'
    link_to '%s unread page%s in your inbox'.t % [@unread_count, s],
      :controller => 'inbox', :action => 'index', :path => 'unread'
  end

  def pending_inbox_link
    s = @pending_count == 1 ? '' : 's'
    link_to '%s pending page%s in your inbox'.t % [@pending_count, s],
      :controller => 'inbox', :action => 'index', :path => 'pending'
  end
  
  def me_cache_key
    params.merge(:user_id => current_user.id, :version => current_user.version)
  end

end
