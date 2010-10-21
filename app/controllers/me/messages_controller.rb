#
# A Message is a resource (in a REST sense) that is the discussion model that is associated
# with current_user and one other user. 
# 
# Each Message has many Posts
#
# In this controller, the :id of a message is the login name of the other user. 
# In other words, the message with :id => 'green' identifies the discussion (with many posts) between the current user
# and the user green.
#
# for example: 'GET /me/messages/green' request gets the whole private discussion between current_user and user green
#

class Me::MessagesController < Me::BaseController
  helper 'autocomplete', 'javascript'

  # GET /me/messages
  def index
    @discussions = current_user.discussions.with_some_posts.send(view).paginate(pagination_params)
  end

  # GET /me/messages/penguin
  def show
    @other_user = User.find_by_login(params[:id])
    @discussion = current_user.discussions.from_user(@other_user).first
    @discussion.mark!(:read, current_user)
    @posts = @discussion.posts.paginate(post_pagination_params)
  rescue Exception => exc
    render_error exc  
  end

  # PUT /me/messages/penguin
  def update
    @other_user = User.find_by_login(params[:id])
    @discussion = current_user.discussions.from_user(@user_user).first
    if params[:state]
      @discussion.mark!(params[:state], current_user)
    end
  rescue Exception => exc
    render_error exc
  end

  protected

  def view
    params[:view] if ['all','unread'].include?(params[:view])
  end
  
  def post_pagination_params
    default_page = params[:page].blank? ? @discussion.last_page : nil
    pagination_params(:page => default_page)
  end

end
