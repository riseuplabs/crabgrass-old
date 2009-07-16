class Networks::DirectoryController < Groups::DirectoryController

  def my
    @groups = current_user.groups.only_type(@group_type).alphabetized('').paginate(:all, :page => params[:page])
    @show_committees = true
    render_list
  end

  protected
  
  def context
    network_context
  end

  def set_group_type
    @group_type = :network
  end

end
