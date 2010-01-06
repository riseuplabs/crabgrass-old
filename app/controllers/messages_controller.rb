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
    # show the last page if page param is not set
    # instead of the usual first page
    default_page = nil
    if params[:page].blank?
      total_entries = @discussion.posts.count
      total_pages = (total_entries.to_f / @discussion.posts.per_page).ceil
      # total_pages is 0 when total_entries is 0
      total_pages = 1 if total_pages == 0
      default_page = total_pages
    end

    # not so RESTful modifying the record on a GET request

    @discussion.mark!(:read, current_user)
    @posts = @discussion.posts.paginate(page_params(default_page, 10))
  end

  ### REDIRECT ACTIONS ###

  def next
    next_recipient = @discussion.next_for(current_user).try.user_talking_to(current_user)
    redirect_to_message(next_recipient)
  end

  def previous
    previous_recipient = @discussion.previous_for(current_user).try.user_talking_to(current_user)
    redirect_to_message(previous_recipient)
  end

  protected

  def redirect_to_message(recipient)
    redirect_direction = recipient.blank? ? {:action => :index} : message_path(recipient.login)
    redirect_to redirect_direction
  end

  def authorized?
    # controller only manipulates current_user.discussions objects
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
    @discussion = current_user.discussions.from_user(@user).first
  end

  def fetch_recipient
    @recipient = @discussion.user_talking_to(current_user)
  end

  # default page when no page param is present can be nil
  # in some cases, it should be the last page
  def page_params(default_page = nil, per_page = nil)
    {:page => params[:page] || default_page, :per_page => per_page}
  end

end
