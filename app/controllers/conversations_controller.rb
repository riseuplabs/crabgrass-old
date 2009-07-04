#
# A controller for private conversations
#
# A "conversation" is a discussion, but we limit access to only two people.
# These two people always share the same discussion record whenever they send
# messages back and forth
#
class ConversationsController < ApplicationController
    
  before_filter :fetch_data, :login_required
  permissions :posts

  # GET /conversations
  def index
    @discussions = current_user.discussions.paginate(:page => params[:page], :order => 'replied_at DESC', :include => :relationships)
  end

  # GET /conversations/<username>
  def show
    fetch_data
    @relationship.update_attributes(:viewed_at => Time.now, :unread_count => 0)
    @posts = @discussion.posts.paginate(:page => params[:page], :order => 'created_at DESC')
    @last_post = @posts.first
  rescue Exception => exc
    flash_message_now :exception => exc
  end

  # PUT /conversations/<username>
  def update
    fetch_data
    @post = @discussion.posts.create do |post|
      post.body = params[:post][:body]
      post.user = current_user
      post.type = "PrivatePost"
      post.in_reply_to = Post.find_by_id(params[:in_reply_to_id])
      post.recipient = @user
    end
    @discussion.increment_unread_for(@user)
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
    if action?(:update)
      may_create_private_message?(@user)
    else
      true
    end
  end

  def fetch_data
    if params[:id]
      @user = User.find_by_login(params[:id])
      @relationship = current_user.relationships.with(@user) || current_user.add_contact!(@user)
      @discussion = @relationship.discussion
    end
  end

  def context
    if @user
      @title_box = content_tag :h1, "Private conversation with {user_name}"[:private_conversation, @user.display_name]
      person_context
      set_breadcrumbs([
        ['me', '/me'],
        ['conversations', conversations_path],
        [h(@user.display_name), conversation_path(:id => @user)]
      ])
    else
      me_context
    end
  end

end
