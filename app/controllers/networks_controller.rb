class NetworksController < GroupsController

  before_filter :check_site_settings, :only => :show

  def initialize(options={})
    super
  end

  def show
    if @current_site and @current_site.network == @group
      redirect_to '/'
    else
      super
      @group_pages = Page.find_by_path(['descending', 'updated_at', 'limit','10'], options_for_groups(@group.group_ids)) if @group
    end
  end

  def new
    @group = Network.new
    render :layout => 'directory'
  end

  def create
    @group = Network.new params[:group]
    @group.save!
    if member_group = Group.find_by_id(params[:group_id])
      if current_user.may?(:admin, member_group)
        @group.add_group!(member_group)
      else
        @group.add_user!(current_user)
      end
    end
    group_created_success
  rescue Exception => exc
    flash_message_now :exception => exc
    render :template => 'groups/new'
  end

  def autocomplete
    if params[:query] == ""
      networks = current_user.networks.find(:all, :limit => 20)
    else
      filter = "#{params[:query]}%"
      networks = Network.find(:all,
        :conditions => ["groups.name LIKE ? OR groups.display_name LIKE ?", filter, filter],
        :limit => 20)
    end
    render_entities_to_json(networks)
  end


  protected

  def context
    ### this is unnecessary
#    if action?(:edit)
#      group_settings_context
    if action?(:create, :new)
      network_context
    else
      network_context
      unless @active_tab == :home
        @left_column = render_to_string(:partial => '/groups/navigation/sidebar')
      end
      if !action?(:show)
        add_context params[:action], networks_url(:action => params[:action], :id => @group, :path => params[:path])
      end
    end
  end

  def check_site_settings
    unless current_site.has_networks?
      redirect_to (current_site.network ? '/' : '/me/dashboard')
    end
  end

  def render_entities_to_json(entities)
    render :json => {
      :query => params[:query],
      :suggestions => entities.collect{|e|display_on_two_lines(e.display_name, h(e.name))},
      :data => entities.collect{|e|e.avatar_id||0}
    }
  end

end

