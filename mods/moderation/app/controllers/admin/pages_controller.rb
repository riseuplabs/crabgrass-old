class Admin::PagesController < Admin::BaseController
  verify :method => :post, :only => [:update]

  permissions 'admin/moderation'

  def index
    params[:view] ||= 'new'
    view = params[:view]
    @current_view = view

    if params[:group] && params[:group].any?
      @group = Group.find(params[:group])
    end

    options = moderation_options.merge :page => params[:page]
    options.merge!({:flow => :deleted}) if view == 'deleted'
    @flagged = Page.paginate_by_path(path_for_view, options)
  end

  # for vetting:       params[:page]['vetted'] == true
  # for hiding:        params[:page]['flow']   == FLOW[:deleted]
  # for making public: params[:page]['public'] == true
  def update
    page_attrs = params[:page].symbolize_keys.slice :vetted, :flow, :public
    @page.update_attributes(page_attrs)
    redirect_to :action => 'index', :view => params[:view]
  end

  # remote action. call with params[:view ] to view the desired pages. ie, hidden, vetted or pending
  def filter
    index
  end

  # Approves a page by marking :vetted = true
  def approve
    @flag.approve
    redirect_to :action => 'index', :view => params[:view]
  end

  # Reject a page by setting flow=FLOW[:deleted], the page will now be 'deleted'(hidden)
  def trash
    @flag.trash
    redirect_to :action => 'index', :view => params[:view]
  end

  # undelete a page by setting setting flow=nil, the page will now be 'undeleted'(unhidden)
  def undelete
    @flag.undelete
    redirect_to :action => 'index', :view => params[:view]
  end

  # set page.public = true for a page which has its flag public_requested = true
  def update_public
    @page.update_attributes({:public => params[:public], :public_requested => false})
    redirect_to :action => 'index', :view => params[:view]
  end

# set page.public = false
  def remove_public
    @page.update_attributes({:public => false, :public_requested => true})
    redirect_to :action => 'index', :view => params[:view]
  end

  protected

  def set_active_tab
    @active_tab = :moderation
    @admin_active_tab = 'page_moderation'
  end

  def path_for_view
    case params[:view]
    when 'all'
      then "/descending/updated_at"
    when 'public requested'
      then "/descending/created_at/public_requested/"
    when 'public'
      then "/descending/created_at/public/"
    when 'new'
      then "/descending/created_at/moderation/new"
    when 'vetted'
      then "/descending/created_at/moderation/vetted"
    when 'deleted'
      then "/descending/created_at/moderation/deleted"
    end
  end

  def authorized?
    if action?(:index)
      may_see_moderation_panel?
    else
      may_moderate?
    end
  end

  prepend_before_filter :fetch_flagged
  def fetch_flagged
    return unless params[:id]
    @page = Page.find params[:id]
    @flag = @page.try.moderated_flags.first
  end

end

