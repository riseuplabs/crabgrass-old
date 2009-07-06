class MessagesController < ApplicationController

  verify :method => :post, :only => [:destroy, :create, :set_status]
  helper 'messages', 'context'
  permissions 'messages'
  stylesheet 'messages'

  before_filter :login_required

  def index
    @posts = @discussion.posts.paginate(:order => 'created_at DESC', :page => params[:page])
  end

  def show
    @post = @discussion.posts.find_by_id(params[:id])
  end

  def destroy
    post = Post.find params[:id]
    post.destroy
    redirect_to url_for(:action => nil)
  end

  def create
    @post = PublicPost.create() do |post|
      post.body = params[:post][:body]
      post.discussion = @user.discussion
      post.user = current_user
      post.recipient = @user
      # enforce a restricted lite mode for wall messages
      post.body_html = GreenCloth.new(post.body, 'page', [:lite_mode]).to_html
    end
  rescue ActiveRecord::RecordInvalid => exc
    flash_message :exception => exc
  ensure   
    redirect_to referer
  end

  def set_status
    @post = StatusPost.create do |post|
      post.body = params[:post][:body]
      post.body = post.body[0..140] if post.body
      post.discussion = current_user.discussion
      post.user = current_user
      post.recipient = current_user
      post.body_html = GreenCloth.new(post.body, 'page', [:lite_mode]).to_html
    end
  rescue ActiveRecord::RecordInvalid => exc
    flash_message :exception => exc
  ensure
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

    @discussion = @user.discussion
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
