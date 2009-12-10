class Groups::ProfilesController < Groups::BaseController

  helper 'profile', 'groups', 'groups/permissions'
  before_filter :fetch_data, :login_required

  def show
  end

  def edit
    update if request.post?
  end

  def media
    update if request.post?
  end

  def permissions
    update if request.post?
  end

  protected

  def update
    if params[:clear_photo]
      @profile.photo.destroy; @profile.photo = nil
    elsif params[:clear_video]
      @profile.video.destroy; @profile.video = nil
    else
    @profile.save_from_params params['profile']
    if @profile.valid?
      flash_message_now :success
    else
      flash_message_now :object => @profile
    end
    end
  end

  def fetch_data
    if params[:id]
      @group = Group.find_by_name(params[:id])
      @profile = @group.profiles.public
    end
    true
  end

  def context
    group_settings_context
  end

  def authorized?
    may_edit_profile?
  end

end

