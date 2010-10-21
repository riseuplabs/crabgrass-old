class Me::RequestsController < Me::BaseController

  def index
    @requests = Request.
      having_state(current_state).
      send(current_view, current_user).
      by_updated_at.
      paginate(pagination_params)
  end

  # for now, no detailed view of a request :(
  #def show
  #end
  #def edit
  #end

  def update
    request = Request.find(param[:id])
    mark_as = params[:as].to_sym
    request.mark!(mark_as, current_user)
  rescue Exception => exc
    render_error exc
  end

  protected

  def current_view
    case params[:view]
      when "all" then :to_or_created_by_user;
      when "to_me" then :to_user;
      when "from_me" then :created_by;
    end
  end

  def current_state
    params[:state]
  end

end
