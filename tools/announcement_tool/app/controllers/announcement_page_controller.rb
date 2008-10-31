class AnnouncementPageController < WikiPageController
  def create
    @page_class = AnnouncementPage
    @stylesheet = 'page_creation'
    if params[:cancel]
      return redirect_to(create_page_url(nil, :group => params[:group]))
    elsif request.post?
      begin 
        @page = AnnouncementPage.create!(
          params[:page].merge(
            :user => current_user, 
            :share_with => params[:recipients],
            :access => (params[:access]||'view').to_sym
          )
        )
        @wiki = Wiki.create!(:user => current_user, :body => params[:body])
        @page.update_attribute(:data, @wiki)
        redirect_to(page_url(@page))
      rescue Exception => exc
        @wiki.destroy if @wiki
        @page = exc.record if exc.record.is_a? Page
        flash_message_now :exception => exc
      end
    end
  end

  # needed to pick up view/announcement_page/show
  def show
  end

  private
  
  # dump the sidebar
  def setup_default_view() end
  
  def fetch_wiki
    return true unless @page
    raise "Announcement has no Content" unless @wiki = @page.data
    @locked_for_me = !@wiki.editable_by?(current_user) if logged_in?
  end

end
