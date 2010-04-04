class Networks::DirectoryController < Groups::DirectoryController

  def search
    @second_nav = 'all'
    super
  end

  protected

  def my_groups
    @groups = current_user.groups.only_type(@group_type, @current_site).alphabetized('').paginate(:all, :page => params[:page])
  end

  def context
    network_context
  end

  def set_group_type
    @group_type = :network
  end

end
