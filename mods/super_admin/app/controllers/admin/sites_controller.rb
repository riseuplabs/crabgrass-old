class Admin::SitesController < Admin::BaseController
  
  verify :method => [:post, :put], :only => :update, :redirect_to => { :action => 'basic' }

  before_filter :set_active_tab
  
  def basic
    @active = 'siteadmin_basic'
    render :template => 'admin/sites/basic'
  end
  
  def profile
    @active = 'siteadmin_profile'
    render :template => 'admin/sites/profile'
  end
  
  def signup
    @active = 'siteadmin_signup'
    render :template => 'admin/sites/signup'
  end
  
  def update
    if params[:site]
      if current_site.update_attributes(params[:site])
        flash[:notice] = 'Site Settings successfully updated.'
      else
        flash[:notice] = 'An error occured, trying to update site settings'
      end
    end
    redirect_to :back
  end
  
  protected
  
  def set_active_tab
    @active = [ 'siteadmin', params[:action] ].join('_')
  end
end
