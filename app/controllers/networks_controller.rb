class NetworksController < GroupsController
 
  def index() redirect_to(:action => 'list') end

  def list
    @networks = Network.visible_by(current_user).paginate(:all, :page => params[:page], :order => 'full_name')
  end

  def create
    @group_type = 'network'
    if request.get?
      @group = Network.new(params[:group])
    elsif request.post?
      if group = Group.find_by_id(params[:group_id])
        verify_access_to!(group)
      end
      @group = Network.create!(params[:group])
      if group
        @group.add_group!(group)
      else
        @group.add_user!(current_user)
      end
      flash_message :success => '%s was successfully created.'.t % 'Network'.t
      redirect_to url_for_group(@group)
    end
  rescue Exception => exc
    @group = exc.record
    flash_message :exception => exc
  end
  
  protected

  def setup_view
     network_context
     set_banner "networks/banner", Style.new(:background_color => "#1B5790", :color => "#eef")
  end

  # verifies that the membership list is kosher
  def verify_access_to!(group)
    raise PermissionDenied.new('you must be a member of the group') unless current_user.member_of?(group)
  #  in_users = users.detect {|u| u == current_user}
  #  in_groups = groups.detect {|g| current_user.member_of?(g) }
  #  raise ErrorMessage.new('You must add yourself or be a member of at least one group in the membership list'[:create_network_membership_error]) unless in_users or in_groups
  end

end
