class Me::DashboardController < Me::BaseController

  def index
    @pages = Page.find_by_path('descending/updated_at/ascending/group_name/limit/40', options_for_me)
    @activities = Activity.for_dashboard(current_user).newest.unique.find(:all)
    @announcements = Page.find_by_path('limit/3/descending/created_at', options_for_me(:flow => :announcement))
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

