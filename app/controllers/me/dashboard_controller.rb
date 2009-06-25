class Me::DashboardController < Me::BaseController
  
  def index
    params[:path] = ['descending', 'updated_at'] if params[:path].empty?
    params[:path] += ['limit','40']
    
    @pages = Page.find_by_path(params[:path], options_for_me)
    @activities = Activity.for_dashboard(current_user).only_visible_groups.newest.unique.find(:all, :limit => 12)
    @announcements = Page.find_by_path('limit/3/descending/created_at', options_for_user(current_user, :flow => :announcement))
    current_user.ensure_discussion
    @current_status = current_user.current_status
  end
  
  def show_welcome_box
    current_user.update_or_create_setting(:show_welcome => true)
    render(:update) {|page| page.replace 'welcome_box', :partial => 'welcome_box'}
  end
  
  def close_welcome_box
    current_user.update_or_create_setting(:show_welcome => false)
    render(:update) {|page| page.replace 'welcome_box', :partial => 'welcome_box'}
  end
  
end
