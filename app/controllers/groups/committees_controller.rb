class Groups::CommitteesController < GroupsController

  def new
    @parent = get_parent
    @group = Committee.new
  end

  def create
    @parent = get_parent
    @group = Committee.new params[:group]
    @group.created_by = current_user  # needed for the activity
    @group.save!
    @parent.add_committee!(@group)
    group_created_success
  rescue Exception => exc
    flash_message_now :exception => exc
    render :template => 'groups/new'
  end

  protected

  def authorized?
    true
  end

  def get_parent
    parent = Group.find_by_name(params[:id])
    unless may_create_subcommittees?(parent)
      raise PermissionDenied.new('You do not have permission to create committees under {group}'[:dont_have_permission_to_create_committees, {:group => parent.name}])
    end
    parent
  end

end

