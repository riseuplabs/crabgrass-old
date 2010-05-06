class Me::SocialActivitiesController < Me::BaseController

  # GET /social-activities
  def index
    if request.xhr?
      limit = params[:more] ? 15 : 5
      @activities_drop = Activity.social_activities_for_groups_and_friends(current_user).only_visible_groups.newest.unique.limit_to(limit)
      if params[:count]
        activities_count = @activities_drop.size.to_s
        render :update do |page|
          page.replace_html 'social_activities_count', activities_count
          page.replace_html 'social_activities_list', :partial => '/me/social_activities/activity', :locals => {:no_date => true}, :collection => @activities_drop
        end
      elsif params[:more]
        render :update do |page|
          page.replace_html 'social_activities_list', :partial => '/me/social_activities/activity', :locals => {:no_date => true}, :collection => @activities_drop
          page.remove 'see_more_activities'
        end
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
