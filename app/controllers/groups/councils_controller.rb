class Groups::CouncilsController < Groups::CommitteesController

  def new
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

  protected
  
  def authorized?
    true
  end

end

