# Message is a resource (in a REST sense) which corresponds to the Discussion model
# Each Message has many Posts

# The message is specified by the :id parameter which is here the login name of another user
# and the message with :id => 'green' identifies the discussion (with many posts) between the current user
# and the user green
# for example: 'GET /me/messages/green' request gets the whole private discussion between current_user and user green
class Me::MessagesController < Me::BaseController
  helper 'autocomplete', 'javascript', 'action_bar'

  before_filter :login_required
  before_filter :fetch_from_user, :only => [:index, :mark]
  before_filter :fetch_discussion, :only => [:show, :next, :previous]
  before_filter :fetch_recipient, :only => :show

  verify :xhr => true, :only => :mark
  rescue_from ActiveRecord::RecordInvalid, :with => :invalid_discussion

  # GET /messages
  def index
    params[:view] ||= 'all'
    @discussions = find_index_discussions

    # used by the new message ajax partial
    @discussion = current_user.discussions.build
    @active_tab=:me
  end

  # PUT /messages/mark
  def mark
    params[:view] ||= 'all'
    mark_as = params[:as].to_sym
    # load several discusssions
    selected_discussions = params[:messages].blank? ? [] : current_user.discussions.find(params[:messages])
    selected_discussions.each do |discussion|
      discussion.mark!(mark_as, current_user)
    end

    @discussions = find_index_discussions
    render :partial => 'messages_main_content'
  end

  # GET /messages/penguin
  def show
    # show the last page if page param is not set
    # instead of the usual first page
    default_page = params[:page].blank? ? discussion_last_page : nil

    # not so RESTful modifying the record on a GET request
    @discussion.mark!(:read, current_user)
    @posts = @discussion.posts.paginate(pagination_params(:page => default_page))
    @active_tab=:people
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

  def view_filter
    # view :all or :unread messages
    params[:view].to_sym
  end

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

  def discussion_last_page
    total_entries = @discussion.posts.count
    total_pages = (total_entries.to_f / pagination_default_per_page).ceil

    # total_pages is 0 when total_entries is 0
    total_pages = 1 if total_pages == 0
    total_pages
  end

  # load discussions based on view filters
  def find_index_discussions
    current_user.discussions.with_some_posts.from_user(@from_user).send(view_filter).paginate(pagination_params)
  end

  # trying to do discussion.save! has raised RecordInvalid
  # ether when trying to create a new discussion or trying to update an existing one
  def invalid_discussion(exception)
    flash_message :exception => exception
    redirect_to :action => :index
  end

  def fetch_from_user
    @from_user = User.find_by_login(params[:from])
  end

  def fetch_discussion
    user = User.find_by_login(params[:id])
    @discussion = current_user.discussions.from_user(user).first
    redirect_to :action => :index if @discussion.blank?
  end

  def fetch_recipient
    @recipient = @discussion.user_talking_to(current_user)
  end

end
