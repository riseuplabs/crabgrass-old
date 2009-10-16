class Admin::DiscussionPostsController < Admin::PostsController
  private

  def fetch_posts(view)
    @flagged = ModeratedPost.display_flags(params[:page], view)
    @admin_active_tab = 'page_post_moderation'
  end
end
