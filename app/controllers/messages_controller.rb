# Message is a resource (in a REST sense) which corresponds to the Discussion model
# Each Message has many Posts

# The message is specified by the :id parameter which is here the login name of another user
# and the message with :id => 'green' identifies the discussion (with many posts) between the current user
# and the user green
# for example: 'GET /messages/green' request gets the whole private discussion between current_user and user green
class MessagesController < ApplicationController
  helper 'autocomplete', 'javascript'

  before_filter :login_required
  before_filter :fetch_from_user, :only => :index
  before_filter :fetch_discussion, :only => [:show, :next, :previous]
  before_filter :fetch_recipient, :only => :show

  verify :xhr => true, :only => :mark
  rescue_from ActiveRecord::RecordInvalid, :with => :invalid_discussion

  # GET /messages
  def index
    # view only :all or :unread messages
    view_filter = params[:view].blank? ? :all : params[:view].to_sym

    @discussions = current_user.discussions.with_some_posts.from_user(@from_user).send(view_filter).paginate(page_params)

    # used by the new message ajax partial
    @discussion = current_user.discussions.build
  end

  # PUT /messages/mark
  def mark
    mark_as = params[:as].to_sym
    # load several discusssions
    selected_discussions = params[:messages].blank? ? [] : current_user.discussions.find(params[:messages])
    selected_discussions.each do |discussion|
      discussion.mark!(mark_as, current_user)
    end

    @discussions = current_user.discussions.with_some_posts.paginate(page_params)
    render :partial => 'main_content'
  end

  # GET /messages/penguin
  def show
    @posts = @discussion.posts.paginate(page_params)
  end

  ### REDIRECT ACTIONS ###

  def next
    redirect_to @discussion.next_for(current_user) || :index
  end

  def previous
    redirect_to @discussion.previous_for(current_user) || :index
  end

  protected

  def authorized?
    # only working on current_user.discussions
    logged_in?
  end

  def context
    me_context('large')
    @left_column = render_to_string :partial => 'me/sidebar'
    if action?(:show)
      add_context(I18n.t(:messages), messages_url)
      add_context(h(@recipient.display_name), message_path(@recipient))
    end
  end

  # trying to do discussion.save! has raised RecordInvalid
  # ether when trying to create a new discussion or trying to update an existing one
  def invalid_discussion(exception)
    flash_message :exception => exception
    redirect_to :index
  end

  def fetch_from_user
    @from_user = User.find_by_login(params[:from])
  end

  def fetch_discussion
    @user = User.find_by_login(params[:id])
    @discussion = current_user.discussions.with_user(@user)
  end

  def fetch_recipient
    @recipient = @discussion.user_talking_to(current_user)
  end

  def page_params
    {:page => params[:page]}
  end

end
