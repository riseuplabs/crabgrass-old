class Admin::WallPostsController < Admin::PostsController
  private

  def fetch_posts(options)
    conditions = (options.delete(:conditions) || [])
    conditions[0] = "#{conditions[0] ? conditions[0]+' AND' : ''} discussions.commentable_type = 'User'"
    joins = [:discussion]
    joins << options.delete(:joins) if options[:joins]
    @posts = Post.paginate(options.merge(:page => params[:page], :joins => :discussion, :conditions => conditions))
    @admin_active_tab = 'wall_post_moderation'
  end
end
