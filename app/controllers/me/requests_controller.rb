#
# my requests:
#  my contact requests
#  my membership requests
#
# contact requests:
#   from other to me
#
# membership requests:
#   from other to groups i am admin of
#

class Me::RequestsController < Me::BaseController

  helper 'requests', 'action_bar'

  # pending requests
  def index
    # view_filter = :created_by | :to_user
    @requests = Request.having_state(:pending).send(view_filter, current_user).paginate(page_params)
  end

  def approved
    @requests = Request.having_state(:approved).send(view_filter, current_user).paginate(page_params)
    render :action => :index
  end

  def rejected
    @requests = Request.having_state(:rejected).send(view_filter, current_user).paginate(page_params)
    render :action => :index
  end

  protected

  # returns a named scope to view
  # named scope takes one argument - current_user
  def view_filter
    # return :created_by if view is :from_me
    # return :to_user otherwise (could be :to_me or blank)
    params[:view].to_sym == :from_me ? :created_by : :to_user
  end

  def context
    super
    me_context('small')
  end


  def page_params(default_page = nil, per_page = nil)
    {:page => params[:page] || default_page, :per_page => nil}
  end

end

