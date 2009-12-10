class Admin::DiscussionPostsController < Admin::PostsController
  private

  def fetch_posts(view)
    options = moderation_options.merge :page => params[:page]
    @flagged = Post.paginate_by_path(path_for_view, options)
    @admin_active_tab = 'page_post_moderation'
  end

  def path_for_view
    case params[:view]
    when 'all'
      then "/"
    when 'new'
      then "/moderation/new"
    when 'vetted'
      then "/moderation/vetted"
    when 'deleted'
      then "/moderation/deleted"
    end
  end
end
