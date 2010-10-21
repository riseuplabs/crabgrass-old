class Groups::AppearanceController < Groups::BaseController

  permissions 'groups'
  helper 'groups'
  before_filter :fetch_data, :login_required

  def edit
    update if request.post?
  end

  protected

  def update
    @profile.save_from_params params['profile']
    if @profile.valid?
      flash_message_now :success
    else
      flash_message_now :object => @profile
    end
  end

  def fetch_data
    if params[:id]
      @group = Group.find_by_name(params[:id])
      group_context
      group_settings_context
    end
    true
  end

  def authorized?
    may_admin_group?
  end

end

