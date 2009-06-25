#
# A controller for private conversations
#
# A "conversation" is a discussion, but we limit access to only two people.
# These two people always share the same discussion record whenever they send
# messages back and forth
#
class ConversationsController < ApplicationController
    
  before_filter :login_required
  permissions :posts

  # GET /conversations
  def index
    @discussions = current_user.discussions.paginate(:page => params[:page], :order => 'replied_at DESC')
  end

  # GET /conversations/<username>
  def show
    fetch_data
    @posts = @discussion.posts.paginate(:page => params[:page], :order => 'created_at DESC')
  rescue Exception => exc
    flash_message_now :exception => exc
  end

  # PUT /conversations/<username>
  def update
    fetch_data
    @post = @discussion.posts.create do |post|
      post.body = params[:post][:body]
      post.user = current_user
      #post.type = "PrivatePost"
    end
    redirect_to conversation_path(:id => @user)
  rescue Exception => exc
    flash_message_now :exception => exc
    render :action => 'show'
  end

  # DELETE /conversations/<username>
  def destroy
    fetch_data
    @discussion.destroy
    conversations_url
  end

  protected

  def authorized?
    # the data we show here is keyed to current user, so it is impossible to do
    # anything here which you should not be allowed to do.
    true
  end

  def fetch_data
    if params[:id]
      @user = User.find_by_login(params[:id])
      @relationship = current_user.relationships.with(@user) || current_user.add_contact!(@user)
      @discussion = @relationship.discussion
    end
  end

  def context
    @title_box = content_tag :h1, "Private conversation with {user_name}"[:private_conversation, @user.display_name]
    person_context
  end

end
