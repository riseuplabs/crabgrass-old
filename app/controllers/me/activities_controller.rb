class Me::ActivitiesController < Me::BaseController
  
  #
  # display a list of recent activity
  #
  def index
    @activities = Activity.for_dashboard(current_user).only_visible_groups.newest.unique.find(:all).paginate(:page => params[:page], :per_page => 50)
  end
  
end
