class Admin::AnnouncementsController < Admin::BaseController
  verify :method => :post, :only => [:update]
  
  def index
    @pages = Page.paginate_by_path('descending/created_at', :page => params[:page], :flow => :announcement)
  end

  def destroy
    @page = Page.find_by_id(params[:id])
    @page.destroy
    redirect_to announcements_path
  end

end

