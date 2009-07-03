class PostObserver < ActiveRecord::Observer

  def after_create(post)
    if post.type == "PrivatePost"
      PrivatePostActivity.create(:user_to => post.recipient, :user_from => post.user,
        :post => post, :reply => !post.in_reply_to.nil?)
    end
  end

end

