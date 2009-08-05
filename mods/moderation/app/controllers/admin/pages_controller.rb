class Admin::PagesController < Admin::BaseController
  verify :method => :post, :only => [:update]

  permissions 'admin/moderation'

  def index
    view = params[:view] || 'all'
    @current_view = view

    if params[:group] && params[:group].any?
      @group = Group.find(params[:group])
    end

    if view == 'pending'
      # all pages that have been flagged as inappropriate or have been requested to be made public but have not had any admin action yet.
      options = { :conditions => ['flow IS NULL AND ((vetted = ? AND rating = ?) OR (public_requested = ? AND public = ?))', false, YUCKY_RATING, true, false], :joins => :ratings, :order => 'updated_at DESC' }
    elsif view == 'new'
      options = { :conditions => ['flow IS NULL AND (vetted = ? AND rating = ?)', false, YUCKY_RATING], :joins => :ratings, :order => 'updated_at DESC' }
    elsif view == 'vetted'
      # all pages that have been marked as vetted by an admin (and are not deleted)
      options = { :conditions => ['flow IS NULL AND vetted = ?', true], :order => 'updated_at DESC' }
    elsif view == 'deleted'
      # list the pages that are 'deleted' by being hidden from view.
      options = { :conditions => ['flow = ?',FLOW[:deleted]], :order => 'updated_at DESC' }
    elsif view == 'public requested'
      options = { :conditions => ['public_requested = ?',true], :order => 'created_at DESC' }
    elsif view == 'public'
      options = { :conditions => ['public = ?',true], :order => 'created_at DESC' }
    elsif view == 'all'
      options = { :order => 'updated_at DESC' }
    end
    @pages = (@group ? @group.pages : Page).paginate(options.merge(:page => params[:page]))
  end

  # for vetting:       params[:page][:vetted] == true
  # for hiding:        params[:page][:flow]   == FLOW[:deleted]
  # for making public: params[:page][:public] == true
  def update
    @page = Page.find(params[:id])
    @page.update_attributes(params[:page])
    redirect_to :action => 'index', :view => params[:view]
  end

  # remote action. call with params[:view ] to view the desired pages. ie, hidden, vetted or pending
  def filter
    index
  end

  # Approves a page by marking :vetted = true
  def approve
    page = Page.find params[:id]
    page.update_attribute(:vetted, true)

    # get rid of all yucky associated with the page
    page.ratings.destroy_all
    redirect_to :action => 'index', :view => params[:view]
  end

  # Reject a page by setting flow=FLOW[:deleted], the page will now be 'deleted'(hidden)
  def trash
    page = Page.find params[:id]
    page.update_attribute(:flow, FLOW[:deleted])
    redirect_to :action => 'index', :view => params[:view]
  end

  # undelete a page by setting setting flow=nil, the page will now be 'undeleted'(unhidden)
  def undelete
    page = Page.find params[:id]
    page.update_attribute(:flow, nil)
    redirect_to :action => 'index', :view => params[:view]
  end

  # set page.public = true for a page which has its flag public_requested = true
  def update_public
    page = Page.find params[:id]
    page.update_attributes({:public => params[:public], :public_requested => false})
    redirect_to :action => 'index', :view => params[:view]
  end

# set page.public = false
  def remove_public
    page = Page.find params[:id]
    page.update_attributes({:public => false, :public_requested => true})
    redirect_to :action => 'index', :view => params[:view]
  end

  protected

  def set_active_tab
    @admin_active_tab = 'page_moderation'
  end

  def authorized?
    may_moderate?
  end
end

