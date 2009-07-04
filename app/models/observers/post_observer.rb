class PostObserver < ActiveRecord::Observer

  def after_create(post)
    if post.type == "PrivatePost"
      PrivatePostActivity.create(
        :user_to => post.recipient, :user_from => post.user,
        :post => post, :reply => !post.in_reply_to.nil?
      )
    elsif post.type == "PublicPost" || post.type == "StatusPost"
      MessageWallActivity.create(
        :user => post.recipient, :author => post.user, :post => post
      )
    end
  end

  def after_destroy(post)
    if post.type == "PrivatePost"
      activity = PrivatePostActivity.find_by_related_id(post.id)
      activity.destroy if activity
    elsif post.type == "PublicPost" || post.type == "StatusPost"
      activity = MessageWallActivity.find_by_related_id(post.id)
      activity.destroy if activity
    end
  end

end

