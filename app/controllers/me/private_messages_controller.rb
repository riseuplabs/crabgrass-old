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
    if @recipient
      @relationship.update_attributes(:visited_at => Time.now, :total_visits => @relationship.total_visits+1, :unread_count => 0)
      @posts = @discussion.posts.paginate(:page => params[:page], :order => 'created_at DESC')
      @last_post = @posts.first
    end
  rescue Exception => exc
    flash_message_now :exception => exc
  end

  # POST /my/messages/private/<username>
  def create
    create_private_message
  rescue Exception => exc
    flash_message :exception => exc
    index
    render :action => 'index'
  end

  # PUT /my/messages/private/<username>
  def update
    create_private_message
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
    if current_user == @recipient
      raise ErrorMessage.new("cannot send messages to yourself", :redirect => my_private_messages_url)
    end

    if action?(:update, :create)
      may_create_private_message?(@recipient)
    else
      true
    end
  end

  def fetch_data
    if params[:id]
      @recipient = User.find_by_login(params[:id])
      if @recipient
        @relationship = current_user.relationships.with(@recipient) || current_user.add_contact!(@recipient)
        @discussion = @relationship.discussion
      end
    end
  end

  def context
    super
    if action?(:show)
      add_context(I18n.t(:messages), my_messages_url)
      add_context(I18n.t(:private), my_private_messages_url)
      add_context(h(@recipient.display_name), my_private_message_path(@recipient))
    end
  end

  def create_private_message
    if @recipient.nil?
      raise ErrorMessage.new(I18n.t(:thing_not_found, :thing => params[:id]))
    elsif params[:post].try[:body].empty?
      raise ErrorMessage.new(I18n.t(:message_must_not_be_empty))
    end
    @discussion.increment_unread_for(@recipient)
    @post = @discussion.posts.create do |post|
      post.body = params[:post][:body]
      post.user = current_user
      post.type = "PrivatePost"
      post.in_reply_to = Post.find_by_id(params[:in_reply_to_id])
      post.recipient = @recipient
    end
    redirect_to my_private_message_url(@recipient)
  end

end
