class Admin::PagesController < Admin::BaseController
  verify :method => :post, :only => [:update]

  permissions 'admin/moderation'

  def index
    view = params[:view] || 'new'
    @current_view = view

    if params[:group] && params[:group].any?
      @group = Group.find(params[:group])
    end

    if view == 'all'
      @flagged = Page.paginate({:order=>'updated_at DESC', :page=>params[:page]})
    elsif (view=~/^public/)
      options={:conditions=>['public_requested=?',true]} if view=~/requested/
      options={:conditions=>['public=?',true]} if view=='public'
      options.merge!({:order => 'created_at DESC', :page=>params[:page]})
      @flagged = Page.paginate(options)
    else
      if view == 'new'
        #options = { :conditions => ['moderated_flags.deleted_at IS NULL AND moderated_flags.vetted_at IS NULL'], :joins => 'inner join moderated_flags on pages.id=moderated_flags.foreign_id', :order => 'updated_at DESC'}
        options = {:select => "distinct foreign_id", :conditions => ['vetted_at IS NULL and deleted_at IS NULL'], :order => 'updated_at DESC'}
      elsif view == 'vetted'
        ### vetted means an admin has reviewed the page but decided not to delete.
        # all pages that have been marked as vetted by an admin (and are not deleted)
        options = { :conditions => ['vetted_at IS NOT NULL and deleted_at IS NULL'], :order => 'updated_at DESC' }
      elsif view == 'deleted'
        # list the pages that are 'deleted' by being hidden from view.
        ### might have to select by page here for backwards compatibility
        options = { :select => "distinct foreign_id", :conditions => ['deleted_at IS NOT NULL'], :order => 'updated_at DESC' }
      end
      #@pages = (@group ? @group.pages : Page).paginate(options.merge(:page => params[:page]))
      @flagged = ModeratedPage.paginate(options.merge(:page => params[:page]))
    end
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
    ModeratedPage.update_all('vetted_at=now()',"foreign_id=#{params[:id]}")
    ModeratedPage.find_by_foreign_id(params[:id]).page.update_attribute(:vetted, true)
    # ??? get rid of all yucky associated with the page
    redirect_to :action => 'index', :view => params[:view]
  end

  # Reject a page by setting flow=FLOW[:deleted], the page will now be 'deleted'(hidden)
  def trash
    ModeratedPage.update_all('deleted_at=now()',"foreign_id=#{params[:id]}")
    ModeratedPage.find_by_foreign_id(params[:id]).page.update_attribute(:flow, FLOW[:deleted])
    redirect_to :action => 'index', :view => params[:view]
  end

  # undelete a page by setting setting flow=nil, the page will now be 'undeleted'(unhidden)
  def undelete
    ModeratedPage.update_all("deleted_at=NULL","foreign_id=#{params[:id]}")
    ModeratedPage.find_by_foreign_id(params[:id]).page.update_attribute(:flow, nil)
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
    @active_tab = :moderation
    @admin_active_tab = 'page_moderation'
  end

  def authorized?
    may_moderate?
  end
end

