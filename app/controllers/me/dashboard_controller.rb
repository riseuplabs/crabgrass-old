class Me::DashboardController < Me::BaseController
  
  helper 'wall'

  def index
    @pages = Page.find_by_path('descending/updated_at/ascending/group_name/limit/40', options_for_me)
    @activities = Activity.for_dashboard(current_user).newest.unique.find(:all)
    @announcements = Page.find_by_path('limit/3/descending/created_at', options_for_me(:flow => :announcement))
   @wall_posts  = current_user.discussion.posts.all(:order => 'created_at DESC')
    @current_status = current_user.current_status
  end

#  def page_list
#    return false unless request.xhr?
#    @pages = Page.find_by_path('descending/updated_at/ascending/group_name/limit/40', options_for_me)
#    render :layout => false
#  end

  def add_status_message
    if current_user.discussion.nil?
      current_user.discussion = Discussion.create
    end
    @discussion = current_user.discussion
    # TODO how do we find out if user is allowed to post  in here?
    @post = StatusPost.new(params[:post])
    @post.discussion  = current_user.discussion
    @post.user = current_user
    @post.save!
    current_user.discussion.save
    redirect_to url_for(:controller => 'me/dashboard', :action => nil)
  end

  def delete_wall_post
    @post = Post.find(params[:id] || params[:path].first)
    if current_user.discussion.id == @post.discussion.id
      Post.delete(params[:id] || params[:path].first)
    end
    redirect_to from_url
  end
  
  
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

