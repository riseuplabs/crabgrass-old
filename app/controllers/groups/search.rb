#
# This should be a separate controller, but I had a hard time getting it to play
# nice with the routes unless it was a module. Maybe some day...
#
module Groups::Search

  def search
    if request.post?
      path = parse_filter_path(params[:search])
      redirect_to group_search_url(:action => 'search', :path => path)
    else
      @path.default_sort('updated_at')
      @pages = Page.paginate_by_path(@path, options_for_group(@group).merge(pagination_params))
      hide_users
      search_template('search')
    end
  end

  def archive
    @field = @path.keyword?('updated') ? 'updated' : 'created'

    @months = Page.month_counts(:group => @group, :current_user => (current_user if logged_in?), :field => @field)
    unless @months.empty?
      @current_year  = (Date.today).year
      @start_year    = @months[0]['year'] || @current_year.to_s
      @current_month = (Date.today).month

      # normalize path
      unless @path.keyword?('date')
        @path.merge!( :date => ("%s-%s" % [@months.last['year'], @months.last['month']]) )
      end
      @path.set_keyword(@field)

      # find pages
      @pages = Page.paginate_by_path(@path, options_for_group(@group).merge(pagination_params))
    end
    @tags  = Tag.for_group(:group => @group, :current_user => (current_user if logged_in?))
    search_template('archive')
  end

  def tags
    tags = params[:path] || []
    path = tags.collect{|t|['tag',t]}.flatten
    if path.any?
      @pages   = Page.paginate_by_path(path, options_for_group(@group).merge(pagination_params))
      page_ids = Page.ids_by_path(path, options_for_group(@group))
      @tags    = Tag.for_taggables(Page,page_ids).find(:all)
    else
      @pages = []
      @tags  = Tag.for_group(:group => @group, :current_user => (current_user if logged_in?))
    end
    @second_nav = 'pages'
    search_template('tags')
  end

  def tasks
    @pages = Page.find_by_path(@path.merge(:type => :task), options_for_group(@group))
    @task_lists = @pages.collect{|page|page.data}
    @show_status = params[:status] || 'pending'
    @second_nav = 'tasks'
    search_template('tasks')
  end

  def trash
    @second_nav = 'pages'
    if request.post?
      path = parse_filter_path(params[:search])
      redirect_to url_for_group(@group, :action => 'trash', :path => path)
    else
      @path.default_sort('updated_at')
      @pages = Page.paginate_by_path(@path, options_for_group(@group, :flow => :deleted).merge(pagination_params))
      hide_users
      search_template('trash')
    end
  end

  def discussions
    @path.default_sort('updated_at').merge!(:type => :discussion)
    @pages = Page.paginate_by_path(@path, options_for_group(@group, :include => {:discussion => :last_post}).merge(pagination_params))
    search_template('discussions')
  end

  def contributions
    @path.default_sort('updated_at').merge!(:limit => 20, :contributed_group => @group.id)

    @pages = Page.find_by_path(@path, options_for_contributions).each do |page|
      page.updated_by_id = page.user_id # user_id is from user_participation.
      page.updated_by_login = User.find(page.user_id).login
      page.updated_at = page.changed_at # changed_at is from user_participation.
    end
    search_template('contributions')
  end

  def options_for_contributions
    options_for_me(:select => "DISTINCT pages.*, user_participations.user_id, user_participations.changed_at")
  end

  def pages
    @pages = Page.paginate_by_path(search_path, options_for_group(@group).merge(pagination_params))
    @tags  = Tag.for_group(:group => @group, :current_user => (current_user if logged_in?))
    @second_nav = 'pages'
    @third_nav = 'all_pages'
    search_template('pages')
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
    end
  end
end

