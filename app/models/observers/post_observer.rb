class PostObserver < ActiveRecord::Observer

  def after_create(post)
    if post.private?
      PrivatePostActivity.create(
        :user_to => post.recipient, :user_from => post.user,
        :post => post, :reply => !post.in_reply_to.nil?
      )
    elsif post.default?  # so far these are only status posts
      MessageWallActivity.create(
        :user => post.recipient, :author => post.user, :post => post, :access => 2 
      )
    elsif post.public?
      MessageWallActivity.create(
        :user => post.recipient, :author => post.user, :post => post
      )
    end
  end

  def after_destroy(post)
    if post.private?
      activity = PrivatePostActivity.find_by_related_id(post.id)
      activity.destroy if activity
    elsif post.public?
      activity = MessageWallActivity.find_by_related_id(post.id)
      activity.destroy if activity
    end
  end

end

