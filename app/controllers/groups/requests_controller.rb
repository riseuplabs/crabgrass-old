class Group::RequestsController < Group::BaseController

  permissions 'groups/requests'

  def index
    @requests = Request.
      regarding_group(@group).
      having_state(params[:state]).
      by_created_at.
      paginate(pagination_params)
  end

  # for now, no detailed view of a request :(
  #def show
  #end

  def update
    request = @group.Request.find(param[:id])
    request.mark!(params[:mark], current_user)
  rescue Exception => exc
    render_error exc
  end

  def destroy
    request = @group.Request.find(param[:id])
    request.destroy! if request.may_destroy?(current_user)
  rescue Exception => exc
    render_error exc
  end

  
end
