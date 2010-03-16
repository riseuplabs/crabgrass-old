class Networks::DirectoryController < Groups::DirectoryController

  def my
    @groups = current_user.groups.only_type(@group_type, @current_site).alphabetized('').paginate(:all, :page => params[:page])
    @show_committees = true
    @second_nav = 'my'
    render_list
  end

  def search
    @second_nav = 'all'
    super
  end

  protected

  def context
    network_context
  end

  def set_group_type
    @group_type = :network
  end

end
