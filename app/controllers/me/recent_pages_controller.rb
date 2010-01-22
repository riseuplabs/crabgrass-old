class Me::RecentPagesController < Me::BaseController

  def index
    return false unless request.xhr?
    @recent_pages_list = current_user.pages.recent_pages
  end

  def create
    index
  end
end
