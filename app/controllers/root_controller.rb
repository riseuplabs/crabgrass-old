#
# This controller is in charge of rendering the root url.
#
class RootController < ApplicationController

  helper :groups, :account, :wiki
  stylesheet 'wiki_edit'
  javascript 'wiki_edit'
  permissions 'groups/base'
  before_filter :login_required, :except => ['index']
  before_filter :fetch_network

  def index
    if !logged_in?
      login_page
    elsif current_site.network
      site_home
    else
      redirect_to me_url
    end
  end

  ##
  ## TAB CONTENT, PULLED BY AJAX
  ##

  def featured
    update_page_list('featured_panel',
      :pages => paginate('featured_by', @group.id, 'descending', 'updated_at')
    )
  end

  def most_viewed
    update_page_list('most_viewed_panel',
      :pages => paginate('descending', 'views'),
      :columns => [:views, :icon, :title, :last_updated], 
      :sortable => false
    )
  end

  def announcements
    update_page_list('announcements_panel', 
      :pages => paginate('descending','created_at', :flow => :announcement)
    )
  end

  def recent_pages
    update_page_list('recent_pages_panel', 
      :pages => paginate('descending', 'updated_at'),
      :columns => [:stars, :icon, :title, :last_updated], 
      :sortable => false,
      :show_time_dividers => true
    )
  end

  protected

  def authorized?
    true
  end

  def site_home
    @active_tab = :home
    @group.profiles.public.create_wiki unless @group.profiles.public.wiki
    render :template => 'root/site_home'    
  end

  def login_page
    @stylesheet = 'account'
    @active_tab = :home
    render :template => 'account/index'
  end

  def fetch_network
    @group = current_site.network if current_site and current_site.network
  end

  def paginate(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    Page.paginate_by_path(args, options_for_group(@group, {:page => params[:page], :per_page => 5}.merge(options)))
  end

  def update_page_list(target, locals)
    render :update do |page|
      page.replace_html target, :partial => 'pages/list', :locals => locals
    end
  end

  ##
  ## lists of active groups and users. used by the view. 
  ##

  helper_method :most_active_groups
  def most_active_groups
    Group.only_groups.most_visits.find(:all, :limit => 5)
  end
  
  helper_method :recently_active_groups
  def recently_active_groups
    Group.only_groups.recent_visits.find(:all, :limit => 10)
  end

  helper_method :most_active_users
  def most_active_users
    User.most_active_on(current_site, nil).not_inactive.find(:all, :limit => 5)
  end

  helper_method :recently_active_users
  def recently_active_users
    User.most_active_on(current_site, Time.now - 30.days).not_inactive.find(:all, :limit => 10)
  end

end

