#
# A controller for private messages
#
# All private messages are stored in a discussion object that is shared by
# exactly two people. 
#
# These two people always share the same discussion record whenever they send
# messages back and forth
#
class Me::PrivateMessagesController < Me::BaseController
  
  prepend_before_filter :fetch_data
  permissions 'posts'
  stylesheet 'messages'

  # for autocomplete  
  javascript 'effects', 'controls', 'autocomplete', :action => :index
  helper 'autocomplete'

  # GET /my/messages/private
  def index
    @discussions = current_user.discussions.paginate(:page => params[:page], :order => 'replied_at DESC', :include => :relationships)
  end

  # GET /my/messages/private/<username>
  def show
    @relationship.update_attributes(:viewed_at => Time.now, :unread_count => 0)
    @posts = @discussion.posts.paginate(:page => params[:page], :order => 'created_at DESC')
    @last_post = @posts.first
  rescue Exception => exc
    flash_message_now :exception => exc
  end

  # POST /my/messages/private/<username>
  def create
    update
  end

  # PUT /my/messages/private/<username>
  def update
    @discussion.increment_unread_for(@user)
    @post = @discussion.posts.create do |post|
      post.body = params[:post][:body]
      post.user = current_user
      post.type = "PrivatePost"
      post.in_reply_to = Post.find_by_id(params[:in_reply_to_id])
      post.recipient = @user
    end
    redirect_to my_private_message_url(@user)
  rescue Exception => exc
    flash_message_now :exception => exc
    render :action => 'show'
  end

  # DELETE /my/messages/private/<username>
  def destroy
    @discussion.destroy
    redirect_to my_private_messages_url
  end

  protected

  def authorized?
    if action?(:update, :create)
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
    super
    if action?(:show)
      add_context('Messages'[:messages], my_messages_url)
      add_context('Private'[:private], my_private_messages_url)
      add_context(h(@user.display_name), my_private_message_path(@user))
    end
  end

end
