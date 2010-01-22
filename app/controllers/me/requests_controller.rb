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
    @requests = Request.created_by(current_user).paginate(page_params)
  end

  def approved
    render :action => :index
  end

  def rejected
    render :action => :index
  end


  def from_me
    @requests = Request.created_by(current_user).having_state(params[:state]).by_created_at.paginate(:page => params[:page])
  end

  def to_me
    @requests = Request.to_user(current_user).having_state(params[:state]).by_created_at.paginate(:page => params[:page])
  end

  protected

  def context
    super
    me_context('small')
  end


  def page_params(default_page = nil, per_page = nil)
    {:page => params[:page] || default_page, :per_page => nil}
  end

end

