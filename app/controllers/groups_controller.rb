class GroupsController < Groups::BaseController

  stylesheet 'groups'
  permissions 'groups/memberships', 'groups/requests'

  # needed by for group wiki editing
  javascript :wiki, :only => :show
  stylesheet :wiki_edit

  helper 'groups', 'wiki'

  before_filter :fetch_group, :except => [:create, :new, :index]
  before_filter :login_required, :except => [:index, :show, :archive, :tags, :search]
  verify :method => :post, :only => [:create, :update, :destroy]
  cache_sweeper :avatar_sweeper, :only => [:edit, :update, :create]

  ## TODO: remove all task list stuff from this controller
    helper 'task_list_page' # :only => ['tasks']
    stylesheet 'tasks', :action => :tasks
    javascript :extra, :action => :tasks
  ## end task list cruft

  include Groups::Search

  # called by dispatcher
  def initialize(options={})
    super()
    @group = options[:group]
  end

  def index
    redirect_to group_directory_url
  end

  def show
    @pages = Page.find_by_path(search_path, options_for_group(@group))
    @announcements = Page.find_by_path('limit/3/descending/created_at', options_for_group(@group, :flow => :announcement))
    @profile = @group.profiles.send(@access)
    @wiki = private_or_public_wiki()
    #@activities = Activity.for_group(@group, (current_user if logged_in?)).newest.unique.find(:all)
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new params[:group]
    @group.created_by = current_user  # needed for the activity
    @group.save!
    group_created_success
  rescue Exception => exc
    flash_message_now :exception => exc
    render :template => 'groups/new'
  end

  def edit
    update if request.post?
  end

  def update
    @group.update_attributes(params[:group])
    if @group.valid?
      flash_message_now :success
    else
      @group.reload if @group.name.empty?
      flash_message_now :object => @group
    end
  end

  def destroy
    @group.destroyed_by = current_user  # needed for the activity
    @group.destroy
    if @group.parent
      redirect_to url_for_group(@group.parent)
    else
      redirect_to me_url
    end
  end

  protected

  def fetch_group
    @group = Group.find_by_name params[:id] if params[:id]
    if @group
      if may_show_private_profile?
        @access = :private
      elsif may_show_public_profile?
        @access = :public
      else
        @group = nil
      end
    end
    if @group
      Tracking.insert_delayed(:group => @group, :user => current_user) if current_site.tracking
      return true
    else
      no_context
      render(:template => 'dispatch/not_found', :status => (logged_in? ? 404 : 401))
      return false
    end
  end

  def context
    if action?(:edit)
      group_settings_context
    elsif action?(:create, :new)
      group_context
    else
      super
      if !action?(:show)
        add_context params[:action], url_for_group(@group, :action => params[:action], :path => params[:path])
      end
    end
  end

  # returns a private wiki if it exists, a public one otherwise
  # TODO: make this less ugly, move to models
  def private_or_public_wiki
    if @access == :private and (@profile.wiki.nil? or @profile.wiki.body == '' or @profile.wiki.body.nil?)
      public_profile = @group.profiles.public
      public_profile.create_wiki unless public_profile.wiki
      public_profile.wiki
    else
      @profile.create_wiki unless @profile.wiki
      @profile.wiki
    end
  end

  def search_path
    @path.default_sort('updated_at').merge!(:limit => 20)
  end

  def group_created_success
    flash_message :title => 'Group Created', :success => 'now make sure to configure your group'
    redirect_to groups_url(:action => 'edit')
  end

  def search_template(template)
    if rss_request?
      handle_rss(
        :title => "%s :: %s :: %s" % [@group.display_name, params[:action].t, @path.title],
        :description => @group.profiles.public.summary,
        :link => url_for_group(@group),
        :image => avatar_url_for(@group, 'xlarge')
      )
    else
      render(:template => 'groups/search/%s' % template)
    end
  end

  #def provide_rss
  #  handle_rss :title => @group.name, :description => @group.summary,
  #    :link => url_for_group(@group),
  #    :image => avatar_url_for(@group, 'xlarge')
  #end

end
