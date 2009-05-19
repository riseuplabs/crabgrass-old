class AnnouncementPageController < WikiPageController
  def create
    @page_class = AnnouncementPage
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
    else
      @page = build_new_page(@page_class)
    end
  end

  # needed to pick up view/announcement_page/show
  def show
  end

  private
  
  # dump the sidebar
  def setup_view
    if logged_in? and @page and current_user.may?(:admin,@page)
      @hide_right_column = false
    else
      @hide_right_column = true
    end
    @show_posts = false
    @show_reply = false
  end
  
  def fetch_wiki
    return true unless @page
    raise "Announcement has no Content" unless @wiki = @page.data
    @locked_for_me = !@wiki.editable_by?(current_user) if logged_in?
  end

end
