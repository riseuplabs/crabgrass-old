class BasePage::ParticipationController < ApplicationController

  before_filter :login_required

  verify :method => :post, :only => [:move]
  

  # TODO: add non-ajax version
  # TODO: send a 'made public' message to watchers
  # Requires :admin access
  def update_public
     # bypass moderation queue step for admins	  
     begin
	admin =  Group.find(Site.default.super_admin_group_id).users.find(current_user.id)
	@page.public = ('true' == params[:public])
		
     rescue ActiveRecord::RecordNotFound        
       @page.public_requested = ('true' == params[:public])
       request_sent = @page.public_requested?
    end
    @page.updated_by = current_user
    @page.save
    render :template => 'base_page/participation/show_public_requested_popup' if request_sent
    render :template => 'base_page/participation/reset_public_line' unless request_sent
  end
  
  def close_public_requested
    close_popup
  end
   
end
