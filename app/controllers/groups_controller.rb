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
      @group = @group_class.create!(params[:group])
      flash_message :success => 'Group was successfully created.'.t
      @group.memberships.create :user => current_user, :group => @group
      @parent.add_committee!(@group) if @parent
      redirect_to url_for_group(@group)
    end
  rescue Exception => exc
    @group = exc.record
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
      raise ErrorMessage.new('Could not understand group type %s' % type)
    end
    Kernel.const_get(type.capitalize)
  end

  def get_parent
    parent = Group.find(params[:parent_id]) if params[:parent_id]
    if parent and not current_user.may?(:admin, parent)
      raise ErrorMessage.new('You do not have permission to create committees under %s' % parent.name)
    end
    parent
  end
end

