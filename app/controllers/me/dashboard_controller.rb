class Me::DashboardController < Me::BaseController

  stylesheet 'messages'

  def index
    @activities = Activity.for_dashboard(current_user).only_visible_groups.newest.unique.find(:all, :limit => 12)
    @more_activity_url = my_activities_path
    fetch_data
  end

  #def private_messages
  #  @activities = PrivatePostActivity.for_dashboard(current_user).newest.find(:all, :limit => 20)
  #  fetch_data
  #end

  #def public_messages
  #  @activities = MessageWallActivity.for_dashboard(current_user).newest.find(:all, :limit => 20)
  #  fetch_data
  #end

  def show_welcome_box
    current_user.update_or_create_setting(:show_welcome => true)
    render(:update) {|page| page.replace 'welcome_box', :partial => 'welcome_box'}
  end

  def close_welcome_box
    current_user.update_or_create_setting(:show_welcome => false)
    render(:update) {|page| page.replace 'welcome_box', :partial => 'welcome_box'}
  end

  protected

  def fetch_data
    params[:path] = ['descending', 'updated_at'] if params[:path].empty?
    params[:path] += ['limit','40']

    @pages = Page.find_by_path(params[:path], options_for_me)
    @announcements = Page.find_by_path('limit/3/descending/created_at', options_for_user(current_user, :flow => :announcement))
  end

end
