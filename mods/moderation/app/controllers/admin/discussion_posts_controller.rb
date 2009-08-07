class Admin::DiscussionPostsController < Admin::PostsController
  private

  def fetch_posts(options)
    conditions = (options.delete(:conditions) || [])
    conditions[0] = "#{conditions[0] ? conditions[0]+' AND' : ''} discussions.commentable_type IS NULL"
    joins = [:discussion]
    joins << options.delete(:joins) if options[:joins]
    @posts = Post.paginate(options.merge(:page => params[:page], :joins => joins, :conditions => conditions))
    @admin_active_tab = 'page_post_moderation'
  end
end
