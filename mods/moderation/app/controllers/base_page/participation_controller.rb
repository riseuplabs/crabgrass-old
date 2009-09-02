class BasePage::ParticipationController < BasePage::SidebarController

  before_filter :login_required

  verify :method => :post, :only => [:move]

  def update_public
    if current_user.moderator?
      @page.public = ('true' == params[:public])
    else
      @page.public_requested = ('true' == params[:public])
    end
    current_user.updated(@page)
    @page.save
    render :template => 'base_page/participation/reset_public_line'
  end

  def close_public_requested
    close_popup
  end

end
