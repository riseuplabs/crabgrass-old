class MessagesController < ApplicationController

  verify :method => :post, :only => [:destroy, :create, :set_status]
  helper 'messages', 'context'
  stylesheet 'messages'

  def index
    @posts = @discussion.posts.paginate(:order => 'created_at DESC', :page => params[:page])
  end

  def show
    @post = @discussion.posts.find_by_id(params[:id])
  end

  def destroy
    post = Post.find params[:id]
    post.destroy
    activity = MessageWallActivity.find_by_related_id(post.id)
    activity.destroy
    redirect_to from_url
  end

  def create
    @user.discussion = Discussion.create if @user.discussion.nil?
    @discussion = @user.discussion
    @post = Post.new(params[:post])
    @post.discussion = @user.discussion

    # enforce a restricted lite mode for wall messages
    @post.body_html = GreenCloth.new(@post.body, 'page', [:lite_mode]).to_html

    @post.user = current_user
    @post.save!
    @user.discussion.save!
    
    # this should be in an observer, but the wall posts are not yet
    # identifiable as different from discussion posts. 
    MessageWallActivity.create!({
      :user => @user, :author => current_user, :post => @post
    })

    redirect_to(url_for_user(@user))
  end

  def set_status
    if current_user.discussion.nil?
      current_user.discussion = Discussion.create
    end
    @discussion = current_user.discussion
    @post = StatusPost.new(params[:post])
    @post.body = @post.body[0..140]
    @post.discussion  = current_user.discussion
    @post.user = current_user
    @post.save!
    current_user.discussion.save

    # this should be in an observer, but the wall posts are not yet
    # identifiable as different from discussion posts. 
    MessageWallActivity.create!({
      :user => @user, :author => current_user, :post => @post
    })

    redirect_to url_for(:controller => '/me/dashboard', :action => nil)
  end

  protected

  prepend_before_filter :fetch_user
  def fetch_user
    if params[:user].to_i != 0
      @user = User.find_by_id params[:user]
    else
      @user = User.find_by_login params[:user]
    end

    ## what is this ensure_discussion stuff? I don't like it.
    @discussion = @user.ensure_discussion
  end

  def authorized?
    if !logged_in? or @user.nil?
      false
    elsif action?(:delete, :set_status)
      current_user == @user
    else
      @profile = @user.profiles.visible_by(current_user)
      @profile.may_see?
    end
  end

  def context
    if logged_in? and current_user == @user
      me_context
    else
      person_context
    end
    add_context "Public Message Wall"[:wall_heading], url_for(:controller => '/messages', :user => @user.login, :action => nil)
  end

end
