class Groups::CouncilsController < Groups::CommitteesController
 
  permissions 'groups/base'

  def new
    @parent = get_parent
    @group = Council.new
  end

  def create
    @parent = get_parent
    @group = Council.new params[:group]
    @group.save!
    @parent.add_committee!(@group)
    group_created_success
  rescue Exception => exc
    flash_message_now :exception => exc
    render :template => 'groups/new'
  end

end

