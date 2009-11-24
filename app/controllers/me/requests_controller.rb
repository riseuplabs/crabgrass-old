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

  helper 'requests'

  def from_me
    @requests = Request.created_by(current_user).having_state(params[:state]).by_created_at.paginate(:page => params[:page])
  end

  def to_me
    @requests = Request.to_user(current_user).having_state(params[:state]).by_created_at.paginate(:page => params[:page])
  end

  protected

  before_filter :default_state
  def default_state
    params[:state] ||= 'pending'
  end

  def context
    super
    me_context('small')
    #add_context 'requests', url_for(:controller => 'me/requests', :action => nil)
    #if action?(:to_me)
    #  add_context I18n.t(:requests_to_me), url_for(:controller => '/me/requests', :action => 'to_me')
    #elsif action?(:from_me)
    #  add_context I18n.t(:requests_from_me), url_for(:controller => '/me/requests', :action => 'from_me')
    #end
  end

end

