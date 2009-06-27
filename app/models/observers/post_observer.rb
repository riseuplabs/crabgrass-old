class PostObserver < ActiveRecord::Observer

  def after_create(post)
    if post.type == "PrivatePost"
      if post.in_reply_to
        PrivatePostReplyActivity.create(:user_to => post.recipient, :user_from => post.user, :post => post)
      else
        PrivatePostActivity.create(:user_to => post.recipient, :user_from => post.user, :post => post)
      end
    end
  end

end

