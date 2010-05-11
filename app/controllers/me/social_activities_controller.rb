class Me::SocialActivitiesController < Me::BaseController

  # GET /social-activities
  def index
    if request.xhr?
      limit = (params[:see] == 'more') ? 15 : 5
      see = (params[:see] == 'more') ? 'less' : 'more'
      @activities_drop = Activity.social_activities_for_groups_and_friends(current_user).only_visible_groups.newest.unique.limit_to(limit)
      render :update do |page|
        page.replace_html 'social_activities_list', :partial => '/me/social_activities/activity', :locals => {:no_date => true}, :collection => @activities_drop
        page.replace 'see_more_activities', :partial => '/layouts/base/social_activities_more_less_link', :locals => {:toggle => see}
      end
    else 
      @activities = Activity.social_activities_for_groups_and_friends(current_user).only_visible_groups.newest.unique.paginate(pagination_params)
    end
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
