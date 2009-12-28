class MessagePostsController < ApplicationController
  permissions 'message_posts'

  before_filter :login_required
  before_filter :fetch_discussion
  before_filter :fetch_recipient

  def create
    in_reply_to = Post.find_by_id(params[:in_reply_to_id])
    current_user.send_message!(@recipient, params[:post][:body], in_reply_to_id)

    respond_to do |wants|
      wants.html { redirect_to messages_path }
      wants.js { render :nothing => true }
    end
  end

  protected

  def fetch_discussion
    @user = User.find_by_login(params[:message_id])
    @discussion = current_user.discussions.with(@user)
  end

  def fetch_recipient
    @recipient = @discussion.user_talking_to(current_user)
  end

end
