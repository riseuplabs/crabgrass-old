class Me::DashboardController < Me::BaseController

  def index
     @pages = Page.find_by_path('descending/updated_at/ascending/group_name/limit/40', options_for_me)
  end

  def counts
    return false unless request.xhr?
    options = options_for_me(:flow => [:membership,:contacts])
    path = "/type/request/pending/not_created_by/#{current_user.id}"
    @request_count = Page.count_by_path(path, options)
    @unread_count  = Page.count_by_path('unread',  options_for_inbox)
    #@pending_count = Page.count_by_path('pending', options_for_inbox)
    render :layout => false
  end

#  def page_list
#    return false unless request.xhr?
#    @pages = Page.find_by_path('descending/updated_at/ascending/group_name/limit/40', options_for_me)
#    render :layout => false
#  end

  
  protected

  # it is impossible to see anyone else's me page,
  # so no authorization is needed.
  def authorized?
    return true
  end
  
  def fetch_user
    @user = current_user
  end
  
  def context
    me_context('large')
    add_context 'dashboard', url_for(:controller => 'me/dashboard', :action => nil)
  end
  
end

