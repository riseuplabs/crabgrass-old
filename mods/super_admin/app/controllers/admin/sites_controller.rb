class Admin::SitesController < Admin::BaseController
  def index
    view = params[:view] || 'basic'
    if view == 'basic'
      basic
    elsif view == 'profile'
      profile
    elsif view == 'signup'
      signup
    end
  end
  
  def basic
    @active = 'basic'
    render :template => 'admin/sites/basic'
  end
  
  def profile
    @active = 'profile'
    render :template => 'admin/sites/profile'
  end
  
  def signup
    @active = 'signup'
    render :template => 'admin/sites/signup'
  end
  
  def update
    if params[:site]
      if current_site.update_attributes(params[:site])
        flash[:notice] = 'Site Settings successfully updated.'
        redirect_to :action => 'index', :view => params[:current_view]
      else
        flash[:notice] = 'An error occured, trying to update page settings'
        redirect_to :action => 'index', :view => params[:current_view]
      end
    end
  end  
end
