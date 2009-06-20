#
# This should be a separate controller, but I had a hard time getting it to play
# nice with the routes unless it was a module. Maybe some day...
#
module Groups::Search

  def search
    if request.post?
      path = parse_filter_path(params[:search]).flatten
      redirect_to group_search_url(:action => 'search', :path => path)
    else
      #params[:path] = ['descending', 'updated_at'] if params[:path].empty?
      @pages = Page.paginate_by_path(params[:path], options_for_group(@group, :page => params[:page]))

      if parsed_path.sort_arg?('created_at') or parsed_path.sort_arg?('created_by_login')
        @columns = [:stars, :icon, :title, :created_by, :created_at, :contributors_count]
      else
        @columns = [:stars, :icon, :title, :updated_by, :updated_at, :contributors_count]
      end
      hide_users
      search_template('search')
    end
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
    search_template('archive')
  end

  def tags
    tags = params[:path] || []
    path = tags.collect{|t|['tag',t]}.flatten
    if path.any?
      @pages   = Page.paginate_by_path(path, options_for_group(@group, :page => params[:page]))
      page_ids = Page.ids_by_path(path, options_for_group(@group))
      @tags    = Tag.for_taggables(Page,page_ids).find(:all)
    else
      @pages = []
      @tags  = Page.tags_for_group(:group => @group, :current_user => (current_user if logged_in?))
    end
    search_template('tags')
  end

  def tasks
    @pages = Page.find_by_path('type/task/pending', options_for_group(@group))
    @task_lists = @pages.collect{|page|page.data}
    #render :action => "print_tasks", :layout => false if params[:print]
  end

  def trash
    if request.post?
      path = parse_filter_path(params[:search]).flatten
      redirect_to url_for_group(@group, :action => 'trash', :path => path)
    else
      params[:path] = ['descending', 'updated_at'] if params[:path].empty?
      @pages = Page.paginate_by_path(params[:path], options_for_group(@group, :page => params[:page], :flow => :deleted))
      @columns = [:admin_checkbox, :icon, :title, :deleted_by, :deleted_at, :contributors_count]
      hide_users
      search_template('trash')
    end
  end

  def discussions
    params[:path] = ['descending', 'updated_at'] if params[:path].empty?
    @pages = Page.paginate_by_path(['type','discussion'] + params[:path],
      options_for_group(@group, :page => params[:page], :include => {:discussion => :last_post}))
    @columns = [:icon, :title, :posts, :contributors, :last_post]
    search_template('discussions')
  end

  def contributions
    params[:path] ||= ""
    params[:path] = params[:path].split('/')
    params[:path] += ['descending', 'updated_at'] if params[:path].empty?
    params[:path] += ['limit','20', 'contributed_group', @group.id.to_s]

    @pages = Page.find_by_path(params[:path], options_for_contributions).each do |page|
      page.updated_by_id = page.user_id # user_id is from user_participation.
      page.updated_by_login = User.find(page.user_id).login
      page.updated_at = page.changed_at # changed_at is from user_participation.
    end
    search_template('contributions')
  end

  def options_for_contributions
    options_for_me(:select => "DISTINCT pages.*, user_participations.user_id, user_participations.changed_at")
  end

  private

  def update_trash
    pages = params[:page_checked]
    if pages
      pages.each do |page_id, do_it|
        if do_it == 'checked' and page_id
          page = Page.find_by_id(page_id)
          if page
            if params[:undelete] and may_undelete_base_page?(page)
              page.undelete
            elsif params[:remove] and may_remove_base_page?(page)
              page.destroy
              ## add more actions here later
            end
          end
        end
      end
    end
    if params[:path]
      redirect_to :action => 'trash', :id => @group, :path => params[:path]
    else
      redirect_to :action => 'trash', :id => @group
    end
  end

  def hide_users
    if may_list_memberships?
      @visible_users = @group.users # << wasteful, because we don't always show the form
    else
      @visible_users = []
      @columns.delete(:updated_by)
      @columns.delete(:created_by)
    end
  end
end

