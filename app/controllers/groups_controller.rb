class GroupsController < ApplicationController

  stylesheet 'groups'
  helper 'group'
   
  before_filter :login_required, :only => [:create]

  def index
    if logged_in?
      redirect_to :controller => 'groups', :action => 'my'
    else
      redirect_to :controller => 'groups', :action => 'directory'
    end
  end

  def directory
    user = logged_in? ? current_user : nil
    @groups = Group.visible_by(user).only_groups.paginate(:all, :page => params[:page], :order => 'name')
  end

  def my
    @groups = current_user.groups.sort_by{|g|g.name}
  end

  # login required
  def create
    @group_class = get_group_class
    @group_type = @group_class.to_s.downcase
    @parent = get_parent
    if request.get?
      @group_class.new(params[:group])
    elsif request.post?
      @group = @group_class.create!(params[:group]) do |group|
        group.avatar = Avatar.new
        group.created_by = current_user
      end
      flash_message :success => 'Group was successfully created.'[:group_successfully_created]
      @group.add_user!(current_user)
      @parent.add_committee!(@group, params[:council] == "true" ) if @parent
      redirect_to url_for_group(@group)
    end
  rescue Exception => exc
    @group = exc.record if exc.record.is_a? Group
    flash_message :exception => exc
  end
       
  protected
  
  before_filter :setup_view
  def setup_view
     group_context
     set_banner "groups/banner", Style.new(:background_color => "#1B5790", :color => "#eef")
  end

  def authorized?
    true
  end
  
  def get_group_class
    type = params[:id].any? ? params[:id] : 'group'
    type = 'committee' if params[:parent_id]
    unless ['committee','group','network'].include? type
      raise ErrorMessage.new('Could not understand group type :type'[:dont_understand_group_type] %{:type => type})
    end
    Kernel.const_get(type.capitalize)
  end

  def get_parent
    parent = Group.find(params[:parent_id]) if params[:parent_id]
    if parent and not current_user.may?(:admin, parent)
      raise ErrorMessage.new('You do not have permission to create committees under %s'[:dont_have_permission_to_create_committees] % parent.name)
    end
    parent
  end
end

