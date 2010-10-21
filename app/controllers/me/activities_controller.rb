class Me::ActivitiesController < Me::BaseController

  def index
    @activities = Activity.social_activities_for_groups_and_friends(current_user).only_visible_groups.newest.unique.paginate(pagination_params)
  end

  # REST /me/activities/:id
  def show
  end

  protected

  def view
    case params[:view]
      when 'peers' then 'social_activities_for_groups_and_peers';
      else 'social_activities_for_groups_and_friends';
    end
  end

end
