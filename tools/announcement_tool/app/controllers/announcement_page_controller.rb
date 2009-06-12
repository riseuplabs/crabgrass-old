class AnnouncementPageController < WikiPageController
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

  def build_page_data
    Wiki.new(:user => current_user, :body => params[:body])
  end
end
