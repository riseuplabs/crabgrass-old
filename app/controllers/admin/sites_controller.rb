class Admin::SitesController < Admin::BaseController
  verify :method => [:post, :put], :only => :update, :redirect_to => { :action => 'basic' }

  permissions 'admin/sites'

  before_filter :set_active_tab

  def basic
  end

  def profile
  end

  def signup
  end

  def update
    if params[:site]
      if current_site.update_attributes(params[:site])
        flash[:notice] = 'Site Settings successfully updated.'
      else
        flash[:notice] = 'An error occured, while updating site settings'
      end
    end
    redirect_to :back
  end
end
