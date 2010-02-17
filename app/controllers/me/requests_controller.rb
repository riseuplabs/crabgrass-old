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
    params[:view] ||= "to_me"
    @requests = Request.having_state(:pending).send(current_view_named_scope, current_user).paginate(page_params)
  end

  def approved
    params[:view] ||= "all"
    @requests = Request.having_state(:approved).send(current_view_named_scope, current_user).paginate(page_params)
    render :action => :index
  end

  def rejected
    params[:view] ||= "all"
    @requests = Request.having_state(:rejected).send(current_view_named_scope, current_user).paginate(page_params)
    render :action => :index
  end

  def mark
    params[:view] ||= "to_me"
    mark_as = params[:as].to_sym
    # load requests to mark
    requests = params[:requests].blank? ? [] : Request.having_state(:pending).to_or_created_by_user(current_user).find(params[:requests])
    requests.each do |request|
      request.mark!(mark_as, current_user)
    end

    @requests = Request.having_state(:pending).send(current_view_named_scope, current_user).paginate(page_params)
    render :partial => 'main_content'
  end

  protected

  # returns a named_scope for Request that takes 1 argument - current_user
  def current_view_named_scope
    scopes = {
      "all" => :to_or_created_by_user,
      "to_me" => :to_user,
      "from_me" => :created_by}

    scopes[params[:view]]
  end

  def context
    super
    me_context('small')
  end

  def page_params(default_page = nil, per_page = nil)
    {:page => params[:page] || default_page, :per_page => nil}
  end

end

