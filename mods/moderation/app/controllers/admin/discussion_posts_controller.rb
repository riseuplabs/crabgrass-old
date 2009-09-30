class Admin::DiscussionPostsController < Admin::PostsController
  private

  def fetch_posts(options)
    conditions = (options.delete(:conditions) || [])
    @flagged = ModeratedPost.paginate(options.merge(:page => params[:page], :conditions => conditions, :select => 'distinct foreign_id'))
    @admin_active_tab = 'page_post_moderation'
  end
end
