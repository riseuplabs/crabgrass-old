class Me::SocialActivitiesController < Me::BaseController

  # GET /social-activities
  def index
    @activities = Activity.social_activities_for_groups_and_friends(current_user).only_visible_groups.newest.unique.paginate(pagination_params)
  end

  # GET /social-activities/peers
  def peers
    @activities = Activity.social_activities_for_groups_and_peers(current_user).only_visible_groups.newest.unique.paginate(pagination_params)
    render :action => :index
  end

  protected

  def authorized?
    logged_in?
  end
end
