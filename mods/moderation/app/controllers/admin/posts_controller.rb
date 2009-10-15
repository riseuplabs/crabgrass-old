class Admin::PostsController < Admin::BaseController
  verify :method => :post, :only => [:update]

  permissions 'admin/moderation'

  def index
    params[:view] ||= 'new'
    view = params[:view]
    @current_view = view
    if view == 'all'
      @flagged = Post.paginate({ :order => 'updated_at DESC', :page => params[:page]})
    else
      # defined by subclasses
      fetch_posts(view)
    end
  end

  # for vetting:       params[:post][:vetted] == true
  # for hiding:        params[:post][:deleted] == true
  def update
    @posts = Post.find(params[:id])
    @posts.update_attributes(params[:post])
    redirect_to :action => 'index', :view => params[:view]
  end


  # Approves a post by marking :vetted = true
  def approve
    ModeratedPost.approve(params[:id])
    redirect_to :action => 'index', :view => params[:view]
  end

  # We use delete to hide a post.
  def trash
    mpost = ModeratedPost.find_by_foreign_id(params[:id])
    mpost.trash
    #ModeratedPost.trash(params[:id])
    redirect_to :action => 'index', :view => params[:view]
  end

  # Undelete a hidden post in order to show it.
  def undelete
    mpost = ModeratedPost.find_by_foreign_id(params[:id])
    mpost.undelete
    redirect_to :action => 'index', :view => params[:view]
  end

  def set_active_tab
    @active_tab = :moderation
  end

  def authorized?
    may_moderate?
  end
end

