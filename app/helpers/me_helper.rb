module MeHelper

  def task_link(text, id, default=false)
    if default and params[:id].empty?
      selected = 'selected'
    else
      selected = id == params[:id] ? 'selected' : ''
    end
    url = url_for :controller => 'me', :action => 'tasks', :id => id
    link_to text, url, :class => "tasklink #{selected}"
  end
  
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
  
end
