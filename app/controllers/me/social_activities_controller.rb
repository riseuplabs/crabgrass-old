class Me::SocialActivitiesController < Me::BaseController

  # GET /social-activities
  def index
    @activities = Activity.social_activities_for_groups_and_friends(current_user).only_visible_groups.newest.unique.paginate(page_params)
  end

  # GET /social-activities/peers
  def peers
    @activities = Activity.social_activities_for_groups_and_peers(current_user).only_visible_groups.newest.unique.paginate(page_params)
    render :action => :index
  end

  protected


  def page_params(default_page = nil, per_page = nil)
    {:page => params[:page] || default_page, :per_page => nil}
  end

  def authorized?
    logged_in?
  end
end
