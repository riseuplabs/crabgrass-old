
class GroupController < ApplicationController
  include GroupHelper
  helper 'task_list_page', 'tags' # remove task_list_page when tasks are in a separate controller

  stylesheet 'groups'
  stylesheet 'tasks', :action => :tasks
  javascript :extra, :action => :tasks

  prepend_before_filter :find_group
  
  before_filter :login_required, :except => [:show, :archive, :tags, :search]
  before_filter :render_sidebar
  
  verify :method => :post, :only => [:destroy, :update]

  def initialize(options={})
    super()
    @group = options[:group] # the group context, if any
  end  

  def show
    if logged_in? and (current_user.member_of?(@group) or current_user.member_of?(@group.parent_id))
      @access = :private
    elsif @group.publicly_visible_group
      @access = :public
    else
      clear_context
      return render(:template => 'dispatch/not_found')
    end

    params[:path] ||= ""
    params[:path] = params[:path].split('/')
    params[:path] += ['descending', 'updated_at'] if params[:path].empty?
    params[:path] += ['limit','20']

    @pages = Page.find_by_path(params[:path], options_for_group(@group))
    @announcements = Page.find_by_path('limit/3/descending/created_at', options_for_group(@group, :flow => :announcement))

    @profile = @group.profiles.send(@access)
    @committees = @group.committees_for @access
    @activities = Activity.for_group(@group, (current_user if logged_in?)).newest.unique.find(:all)

    @wiki = private_or_public_wiki()
  end

  def archive
    @path = params[:path] || []
    @parsed = parse_filter_path(params[:path])
    @field = @parsed.keyword?('updated') ? 'updated' : 'created'

    @months = Page.month_counts(:group => @group, :current_user => (current_user if logged_in?), :field => @field)

    unless @months.empty?
      @current_year  = (Date.today).year
      @start_year    = @months[0]['year'] || @current_year.to_s
      @current_month = (Date.today).month

      # normalize path
      unless @parsed.keyword?('date')
        @path << 'date'<< "%s-%s" % [@months.last['year'], @months.last['month']] 
      end
      @path.unshift(@field) unless @parsed.keyword?(@field)
      @parsed = parse_filter_path(@path)

      # find pages
      @pages = Page.paginate_by_path(@path, options_for_group(@group, :page => params[:page]))

      # set columns
      if @field == 'created'
        @columns = [:icon, :title, :created_by, :created_at, :contributors_count]
      else
        @columns = [:icon, :title, :updated_by, :updated_at, :contributors_count]
      end
    end
  end
    
  def tags
    tags = params[:path] || []
    path = tags.collect{|a|['tag',a.gsub('+',' ')]}.flatten
    if path.any?
      @pages   = Page.paginate_by_path(path, options_for_group(@group, :page => params[:page]))
      page_ids = Page.ids_by_path(path, options_for_group(@group))
      @tags    = Tag.for_taggables(Page,page_ids).find(:all)
    else 
      @pages = []
      @tags  = Tag.page_tags_for_group(@group)
    end
  end

  def tasks
    @pages = Page.find_by_path('type/task/pending', options_for_group(@group))
    @task_lists = @pages.collect{|page|page.data}
  end

  # login required
  def edit
  end

  # login required
  # edit the featured content
  def edit_featured_content
    raise PermissionDenied.new("You cannot administrate this group."[:group_administration_not_allowed_error]) unless(current_user.may?(:admin,@group))
    case params[:mode]
      when "unfeatured"
        @content = @group.find_unstatic.paginate(:page => params[:page], :per_page => 20)
      when "expired"
        @content = @group.find_expired.paginate(:page => params[:page], :per_page => 20)
      else
        @content = @group.find_static.paginate(:page => params[:page], :per_page => 20)
    end
  
  end

  # login required
  # mark one page as featured content
  def feature_content
    raise ErrorMessage.new("Page not part of this group"[:page_not_part_of_group]) if !(@page = @group.participations.find_by_page_id(params[:featured_content][:id]))
    if current_user.may?(:admin, @group) 
      year = params[:featured_content][:"expires(1i)"]
      month = params[:featured_content][:"expires(2i)"]
      day = params[:featured_content][:"expires(3i)"]
      date = DateTime.parse("#{year}/#{month}/#{day}") if year && month && day

      case params[:featured_content][:mode].to_sym
      when :feature
        @page.static!(date || nil)
      when :reactivate
        @page.static_expired = nil
        @page.static!(date || nil)
      when :unfeature
        @page.unstatic!
      end
      redirect_to group_url(:action => 'edit_featured_content', :id => @group)
    else
      raise PermissionDenied.new("You cannot administrate this group"[:group_administration_not_allowed_error])
    end
  rescue => exc
    flash_message_now :exception => exc
    render :action => 'edit_featured_content'
  end
  
  # login required
  # updates the list of featured pages
  def update_featured_pages
    
    # use this for group_level featured content 
     
    unstatic = @group.participations.find_all_by_static(true)
    static = @group.participations.find_all_by_page_id(params[:group][:featured_pages]) if params[:group] && params[:group][:featured_pages]
    if static
      unstatic = unstatic-static
      
      static.each do |p|
        p.static! unless p.static
      end
    end   
    unstatic.each do |p|
      p.unstatic! if p.static
    end
        
   # use this for platformwide featured content
   # Page.find(params[:group][:featured_pages]).each(&:static!)
    redirect_to url_for_group(@group)
   rescue => exc
     flash_message_now :exception => exc
     render :action => 'edit'
  end
     
  # login required
  # post required
  # TODO: this is messed up.
  def update
    @group.update_attributes(params[:group])
    
    if params[:group]
      @group.publicly_visible_group         = params[:group][:publicly_visible_group]
      @group.publicly_visible_committees    = params[:group][:publicly_visible_committees]
      @group.publicly_visible_members       = params[:group][:publicly_visible_members]
      @group.accept_new_membership_requests = params[:group][:accept_new_membership_requests]
      @group.min_stars = params[:group][:min_stars]
      if @group.valid? && may_admin_group? && (params[:group][:council_id] != @group.council_id)
        # unset the current council if there is one
        @group.add_committee!(Group.find(@group.council_id), false) unless @group.council_id.nil?
        
        # set the new council if there is one
        new_council = @group.committees.find(params[:group][:council_id]) unless params[:group][:council_id].empty?
        @group.add_committee!(new_council, true) unless new_council.nil?
      end
    end

    if @group.save
      redirect_to :action => 'edit', :id => @group
      flash_message :success => 'Group was successfully updated.'[:group_successfully_updated]
    else
      flash_message_now :object => @group  
    end
  end
  
  @@additional_tools = ["chat"]
  def edit_tools   
    @available_tools = @site.available_page_types + @@additional_tools
    if request.post?
      @group.group_setting.allowed_tools = []
      @available_tools.each do |p|
        @group.group_setting.allowed_tools << p if params[p]
      end
      @group.group_setting.save

      redirect_to :action => 'edit', :id => @group
    end

    #site defaults?
    @allowed_tools =  ( ! @group.group_setting.allowed_tools.nil? ? @group.group_setting.allowed_tools : @available_tools)
  end
  
  @@layout_widgets = ["group_wiki", "recent_pages"]
  def edit_layout
    @widgets = [''] + @@layout_widgets
    if request.post?
      @group.group_setting.template_data = {}
      @group.group_setting.template_data['section1'] = params['section1']
      @group.group_setting.template_data['section2'] = params['section2']
      @group.group_setting.template_data['section3'] = params['section3']
      @group.group_setting.template_data['section4'] = params['section4']
      @group.group_setting.save

      redirect_to :action => 'edit', :id => @group
    end
  end
  
  # login required
  # post required
  def destroy
    if @group.users.uniq.size > 1 or @group.users.first != current_user
      flash_message :error => 'You can only delete a group if you are the last member'[:only_last_member_can_delete_group]
      redirect_to :action => 'show', :id => @group
    else
      @group.destroyed_by = current_user
      if @group.parent
        parent = @group.parent
        parent.remove_committee!(@group)
        @group.destroy
        redirect_to url_for_group(parent)
      else
        @group.destroy
        redirect_to :controller => 'groups', :action => nil
      end
    end
  end  

  # login not required
  def search
    if request.post?
      path = build_filter_path(params[:search])
      redirect_to url_for_group(@group, :action => 'search', :path => path)
    else
      params[:path] = ['descending', 'updated_at'] if params[:path].empty?
      @pages = Page.paginate_by_path(params[:path], options_for_group(@group, :page => params[:page]))
      if parsed_path.sort_arg?('created_at') or parsed_path.sort_arg?('created_by_login')    
        @columns = [:stars, :icon, :title, :created_by, :created_at, :contributors_count]
      else
        @columns = [:stars, :icon, :title, :updated_by, :updated_at, :contributors_count]
      end
    end
    handle_rss :title => @group.name, :description => @group.summary,
               :link => url_for_group(@group),
               :image => avatar_url_for(@group, 'xlarge')
  end
  
  # login not required
  def discussions
    params[:path] = ['descending', 'updated_at'] if params[:path].empty?
    @pages = Page.paginate_by_path(['type','discussion'] + params[:path],
      options_for_group(@group, :page => params[:page], :include => {:discussion => :last_post}))
    @columns = [:icon, :title, :posts, :contributors, :last_post]
  end

  protected
  
  # returns a private wiki if it exists, a public one otherwise
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
    
  def context
    group_context
    unless action?(:show)
      add_context params[:action], url_for_group(@group, :action => params[:action], :path => params[:path])
    end
  end
  
  def find_group
    @group = Group.find_by_name params[:id] if params[:id]
    true
  end

  def render_sidebar
    @left_column = render_to_string(:partial => 'sidebar') if @group
  end

  @@non_members_post_allowed = %w(archive tags tasks search)
  @@non_members_get_allowed = %w(show members search discussions) + @@non_members_post_allowed
  @@admin_only = %w(update, edit_tools) 
   
  def authorized?
    if request.get? and @@non_members_get_allowed.include? params[:action]
      return true
    elsif request.post? and @@non_members_post_allowed.include? params[:action]
      return true
    elsif @@admin_only.include? params[:action]
      return logged_in? && current_user.may?(:admin,@group)
    else
      return (logged_in? && @group && (current_user.member_of?(@group) || current_user.may?(:admin,@group)))
    end
  end    

  after_filter :update_view_count
  def update_view_count
    Tracking.insert_delayed(:group => @group, :user => current_user) if @site.tracking
  end

  # called when we don't want to let on that a group exists
  # when a user doesn't have permission to see it.  
  def clear_context
    @group = nil
    no_context
  end

end
