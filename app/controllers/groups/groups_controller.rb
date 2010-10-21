class Groups::GroupsController < Groups::BaseController

  helper 'groups'

  # called by dispatcher
  def initialize(options={})
    super()
    @group = options[:group]
  end

  def index
    redirect_to groups_directory_url
  end

  def show
    track
    render_not_found unless @group
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new params[:group]
    @group.created_by = current_user  # needed for the activity
    @group.save!
    flash_message :title => I18n.t(:group_successfully_created), :success => success_text(@group)
    redirect_to groups_settings_path(@group, :action => 'edit')
  rescue Exception => exc
    render_error exc, :template => 'groups/new'
  end

  def edit
    @group ||= Group.find_by_name(params[:group_id])
  end

  def update
    @group.update_attributes(params[:group])
    if @group.valid?
      flash_message :success
      redirect_to :action => 'edit'
    else
      @group.reload if @group.name.empty?
      flash_message_now :object => @group
      render :action => 'edit'
    end
  end

  def destroy
    @group.destroy_by(current_user)

    if @group.parent
      redirect_to url_for_group(@group.parent)
    else
      redirect_to me_url
    end

    flash_message :success => true, :title => I18n.t(:group_destroyed_message, :group_type => @group.group_type)
  end

  protected

  def success_text(group)
    # this seems like it should be is_council? .....
    if group.is_group?
      I18n.t(:group_successfully_created_details_council_info)
    else
      I18n.t(:group_successfully_created_details)
    end
  end

end
