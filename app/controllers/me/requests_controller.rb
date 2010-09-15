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

  include Crabgrass::Hook::Helper

  # pending requests
  def index
    params[:view] = params[:view] || call_hook('default_requests_view') || "to_me"

    if params[:view] == "to_me"
      state_scope = :having_state_for_user
      state_args = [:pending, current_user]
    else
      state_scope = :having_state
      state_args = :pending
    end

    @requests = Request.send(state_scope, *state_args).send(current_view_named_scope, current_user).by_updated_at.paginate(pagination_params)
  end

  def approved
    params[:view] ||= "all"
    @not_checkeable = true

    @requests = Request.having_state(:approved).send(current_view_named_scope, current_user).by_updated_at.paginate(pagination_params)
    render :action => :index
  end

  def rejected
    params[:view] ||= "all"
    @not_checkeable = true

    @requests = Request.having_state(:rejected).send(current_view_named_scope, current_user).by_updated_at.paginate(pagination_params)
    render :action => :index
  end

  def mark
    params[:view] = "to_me"
    mark_as = params[:as].to_sym
    # load requests to mark
    requests = params[:requests].blank? ? [] : Request.having_state(:pending).to_or_created_by_user(current_user).find(params[:requests])
    requests.each do |request|
      request.mark!(mark_as, current_user)
    end

    @requests = Request.having_state_for_user(:pending, current_user).send(current_view_named_scope, current_user).paginate(pagination_params)
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

end

